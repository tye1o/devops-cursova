output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.python_app.arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.python_app.invoke_arn
}

output "s3_bucket_domain" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket_domain_name
}