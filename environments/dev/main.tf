# ECR repository
module "landing_ecr" {
  source       = "../../modules/ecr"
  repo_name    = var.ecr_repo_name
  scan_on_push = var.ecr_scan_on_push
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# OIDC provider
module "github_oidc_provider" {
  source = "../../modules/oidc-provider"
}

# IAM Role for GitHub Actions
module "github_oidc_role" {
  source            = "../../modules/github-oidc-role"
  role_name         = var.github_oidc_role_name
  oidc_provider_arn = var.oidc_provider_arn
  oidc_provider_url = var.oidc_provider_url
  github_org        = var.github_org
  github_repo       = var.github_repo
  github_branch     = var.github_branch
}

# Elastic Kubernetes Cluster
module "eks" {
  source = "../../modules/eks"

  cluster_name            = var.cluster_name
  node_group_name         = var.node_group_name
  node_instance_type      = var.node_instance_type
  desired_capacity        = var.desired_capacity
  min_size                = var.min_size
  max_size                = var.max_size
  vpc_id                  = var.vpc_id
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  kubernetes_version      = var.kubernetes_version
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access

  environment  = var.environment
  project_name = var.project_name

  tags = var.tags

  # argocd/IRSA
  argocd_namespace         = var.argocd_namespace
  argocd_sa_name           = var.argocd_sa_name
  argocd_attach_policy_arn = var.argocd_attach_policy_arn
}

# VPC module
module "vpc" {
  source               = "../../modules/vpc"
  environment          = var.environment
  project_name         = var.project_name
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Optional outputs
output "ecr_repo_url" {
  value = module.landing_ecr.repository_url
}

output "github_oidc_role_arn" {
  value = module.github_oidc_role.role_arn
}

output "github_oidc_provider_arn" {
  value = module.github_oidc_provider.oidc_provider_arn
}