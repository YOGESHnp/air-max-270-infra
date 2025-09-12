terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.region
}

# Create S3 bucket for Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "bootstrap"
  }
}

# Enable versioning for recovery
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "bootstrap"
  }
}
