output "cluster_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}


