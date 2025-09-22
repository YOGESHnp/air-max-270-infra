# 🚀 Air Max 270 EKS Infrastructure

This repository provisions a scalable, multi-environment EKS setup on AWS using Terraform. It supports dynamic cluster creation, modular architecture, and remote state management for reliable, automated deployments.

---

## 📁 Folder Structure

air-max-270-infra/
├── modules/ # Reusable modules (vpc, eks, iam)
├── env/ # Environment-specific variable files
│ ├── dev.tfvars
│ ├── staging.tfvars
│ ├── prod.tfvars
├── main.tf # Central orchestration logic
├── variables.tf # Input variable definitions
├── backend.tf # Remote state configuration (S3 + DynamoDB)

---

## 🧱 Infrastructure Components

- **Remote State Backend**: S3 bucket + DynamoDB table for locking
- **VPC Module**: CIDR block, subnets, NAT gateways
- **IAM Module**: OIDC provider, cluster and node group roles
- **EKS Module**: Cluster provisioning using `for_each` for multi-env support

---

## 🧠 Design Principles

- **Modular**: Each component is isolated and reusable
- **Scalable**: Easily add new clusters via `local.eks_clusters`
- **Environment-Aware**: Uses workspaces and `.tfvars` for clean separation
- **Automated**: CI/CD ready with workspace-driven deployments

---

## 🚀 Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/your-org/air-max-270-infra.git
cd air-max-270-infra
```
