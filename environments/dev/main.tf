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
