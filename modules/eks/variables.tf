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

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "kubernetes_version" {
  type    = string
  default = "1.27"
}

# argocd/irsa
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
  type = bool
  default = true 
}

variable "endpoint_public_access" { 
  type = bool
  default = true 
}
