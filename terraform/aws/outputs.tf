output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.python_app.arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.python_app.invoke_arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for static assets"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "s3_bucket_domain" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket_domain_name
}

output "cloudwatch_log_group" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
} 