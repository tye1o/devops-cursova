variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"  # North Virginia region has good Free Tier support
}

variable "app_environment" {
  description = "Environment for the application"
  type        = string
  default     = "production"
}

variable "environment" {
  description = "Environment name for resource naming"
  type        = string
  default     = "dev"
}

variable "lambda_memory" {
  description = "Memory allocation for Lambda function (MB)"
  type        = number
  default     = 128  # Minimum to stay within Free Tier
}

variable "lambda_timeout" {
  description = "Lambda function timeout (seconds)"
  type        = number
  default     = 10
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.9"
} 