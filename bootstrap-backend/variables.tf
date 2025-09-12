variable "region" {
  description = "AWS region where backend resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "air-max-270-terraform-state"
}

variable "dynamodb_table" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-locks"
}
