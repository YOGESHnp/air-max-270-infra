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
  type = string
}

variable "project_name" {
  type = string
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
  type    = list(string)
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

# EKS module variables
variable "cluster_name" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "vpc_id" {
  type = string
}


variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "tags" {
  type    = map(string)
  default = {}
}


# EKS Autoscaling
variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

# argocd/IRSA
variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_sa_name" {
  type    = string
  default = "argocd-server"
}

variable "argocd_attach_policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

variable "endpoint_private_access" {
  description = "Enable private API access to the EKS cluster"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API access to the EKS cluster"
  type        = bool
  default     = true
}



