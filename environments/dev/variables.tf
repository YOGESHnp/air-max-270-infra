# environments/dev/variables.tf

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "terraform-admin"
}

variable "environment" {
  type    = string
}

variable "project_name" {
  type    = string
}

# ECR module variables
variable "ecr_repo_name" {
  type = string
}
variable "ecr_scan_on_push" {
  type    = bool
  default = false
}

# IAM Role module variables
variable "github_oidc_role_name" {
  type = string
}
variable "github_oidc_policy_arns" {
  type = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
}

# GitHub OIDC variables
variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

