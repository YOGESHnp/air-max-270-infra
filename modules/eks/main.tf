/******************************************************************************
modules/eks/main.tf
Creates:
 - EKS cluster
 - IAM role for EKS control plane
 - IAM role for worker nodes (with required policies)
 - Managed node group
 - EKS OIDC provider (for IRSA)
 - IAM role for ArgoCD service account (IRSA)
 - Kubernetes provider resources: namespace argocd + service account annotated with role ARN
******************************************************************************/

# ---------- Cluster IAM role (EKS control plane) ----------
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# ---------- Node IAM role (EC2 worker nodes) ----------
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ---------- EKS Cluster ----------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnets, var.public_subnets)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  tags = merge({
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}

# optional: wait for cluster data to be available
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

# ---------- Managed Node Group ----------
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = var.max_size
  }

  # instance types or launch_template can be used
  instance_types = [var.node_instance_type]

  tags = merge({
    Name        = "${var.cluster_name}-${var.node_group_name}"
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy
  ]
}

# ---------- OIDC Provider for IRSA (create once per cluster) ----------
# If provider already exists, Terraform will attempt to create another and fail.
# In that case import existing provider into state or use data source.
resource "aws_iam_openid_connect_provider" "eks" {
  url             = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "https://")
  client_id_list  = ["sts.amazonaws.com"]
  # Amazon's root CA thumbprint; this is commonly used but verify if required for your region/account
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10df6"]
}

# ---------- IAM Role for ArgoCD Service Account (IRSA) ----------
resource "aws_iam_role" "argocd" {
  name = "${var.cluster_name}-argocd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # issuer host (without https) + :sub equal to the SA's sub
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.argocd_namespace}:${var.argocd_sa_name}"
          }
        }
      }
    ]
  })
}

# NOTE: Replace AdministratorAccess with a least-privileges policy for production.
resource "aws_iam_role_policy_attachment" "argocd_attach_ecr" {
  role       = aws_iam_role.argocd.name
  policy_arn = var.argocd_attach_policy_arn # e.g., AmazonEC2ContainerRegistryPowerUser
}

# ---------- Kubernetes provider resources (namespace + service account) ----------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name" = "argocd"
    }
  }
}

resource "kubernetes_service_account" "argocd_sa" {
  metadata {
    name      = var.argocd_sa_name
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.argocd.arn
    }
  }
}

# ---------- Outputs ----------
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "argocd_role_arn" {
  value = aws_iam_role.argocd.arn
}

output "argocd_namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}
