variable "role_name" {
  description = "Name of the IAM Role for GitHub Actions OIDC"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  type = string
}

variable "policy_arns" {
  description = "List of IAM managed policy ARNs to attach"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
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