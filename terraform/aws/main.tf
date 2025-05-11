# AWS Lambda Terraform Configuration
provider "aws" {
  region = var.aws_region
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "python_app_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Archive the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../"
  output_path = "${path.module}/lambda_function.zip"
  excludes    = ["terraform", ".git", "k8s-manifests", ".github", "venv"]
}

# Create Lambda function
resource "aws_lambda_function" "python_app" {
  function_name    = "python-app"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  memory_size = 128  # Minimum size to stay within Free Tier
  timeout     = 10   # Seconds

  environment {
    variables = {
      FLASK_ENV = var.app_environment
    }
  }
}

# Create API Gateway
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "python-app-api"
  protocol_type = "HTTP"
}

# Create API Gateway stage
resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true
}

# Integrate API Gateway with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.python_app.invoke_arn
  integration_method = "POST"
}

# Create API Gateway route
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Give API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.python_app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

# Create S3 bucket for static files (optional)
resource "aws_s3_bucket" "app_bucket" {
  bucket = "python-app-static-${var.environment}-${random_string.suffix.result}"
}

# Generate random string for unique S3 bucket name
resource "random_string" "suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

# S3 bucket ACL
resource "aws_s3_bucket_ownership_controls" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "app_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.app_bucket]
  bucket = aws_s3_bucket.app_bucket.id
  acl    = "private"
}

# Outputs
output "lambda_function_name" {
  value = aws_lambda_function.python_app.function_name
}

output "api_gateway_url" {
  value = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
} 