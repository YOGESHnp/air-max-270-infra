# air-max-270-infra

# Technical Report — air-max-270 Observability Stack

**Author:** Yogesh  
**Date:** 12 Sep 2025  
**Repos:**  
- Infra (Terraform): https://github.com/YOGESHnp/air-max-270-infra  

---

## Architectural Justification

### Goals
- Production-grade baseline using **Terraform + Kubernetes + GitOps**
- **Observability** (Loki/Promtail/Grafana) with end-to-end pod logging
- Secure image supply chain via **ECR** + OIDC-based CI
- Repeatable deploys with **Kustomize overlays** and **Argo CD**

### High-level Design
- **VPC:** 2 public, 2 private subnets across AZs; IGW + NAT.  
  Private subnets host **EKS nodes**; public subnets host **ALB** for ingress.
- **EKS:** control plane managed by AWS; managed node group in private subnets.  
- **Ingress:** **AWS Load Balancer Controller** provisions ALB; dev & staging share an ALB via group annotations.
- **GitOps:** Argo CD reconciles desired state from `air-max-270-gitops`.  
  - `apps/react-app/base` + overlays (`dev`, `staging`) with image/tag pinning.  
  - `loki-stack` via Helm chart.
- **Observability:** Promtail tailing container logs → Loki → Grafana dashboards/Explore.

## Security Rationale

- **AWS IAM**
  - **GitHub OIDC** role for CI: push to ECR without long-lived keys.
  - **Node role**: EC2/ECR read; temporary ELB policy attached for ALB controller.  
    **Roadmap:** move controller to **IRSA** with the official minimal policy; detach broad policies from node role.
  - **Cluster role**: EKS service/control-plane policies.
- **Network**
  - Nodes in **private subnets** (no public IPs); ALB in public subnets.
  - Security groups restrict control plane traffic (443) and kubelet (10250) appropriately.
- **Secrets**
  - No plaintext secrets in Git; Grafana admin creds stored as K8s Secret from Helm.  
  - **Roadmap:** External secrets via AWS Secrets Manager; Argo CD sops.
- **Supply Chain**
  - CI builds/pushes to **ECR**; Kustomize overlays pin tags per environment.  
  - **Roadmap:** image signing/verification (Sigstore), admission policy (OPA/Gatekeeper/Kyverno).
- **State**
  - **Roadmap:** remote Terraform state in S3 with DynamoDB locking and encryption.

  ## Verification (Smoke Tests)

- **Cluster health:** `kubectl get nodes -o wide` (Ready).  
- **App:** `kubectl -n app get ingress dev-react-app` → open ALB DNS (200 OK).  
- **Logging:** Grafana → Explore (Loki) → `{namespace="app", pod=~"dev-react-app-.*"}` returns NGINX access logs.