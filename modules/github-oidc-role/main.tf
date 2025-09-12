resource "aws_iam_role" "github_oidc_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${var.oidc_provider_url}:sub" = [
              "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_attach" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

output "role_arn" {
  value = aws_iam_role.github_oidc_role.arn
}