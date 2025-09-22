# 🚀 Air Max 270 EKS Infrastructure

This repository provisions a scalable, multi-environment EKS setup on AWS using Terraform. It supports dynamic cluster creation, modular architecture, and remote state management for reliable, automated deployments.

---

## 📁 Folder Structure

air-max-270-infra/
├── modules/ # Reusable modules
│ ├── vpc/ # VPC provisioning logic
│ ├── eks/ # EKS cluster logic
│ ├── iam/ # IAM roles and OIDC setup
│ └── ... # Add more modules as needed
├── env/ # Environment-specific variable files
│ ├── dev.tfvars # Variables for dev cluster
│ ├── staging.tfvars # Variables for staging cluster
│ ├── prod.tfvars # Variables for prod cluster
├── main.tf # Central orchestration logic
├── variables.tf # Input variable definitions
├── backend.tf # Remote state configuration (S3 + DynamoDB)
├── README.md # Project overview and usage guide

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
