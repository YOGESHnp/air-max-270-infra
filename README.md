# air-max-270-infra

# Technical Report — air-max-270 Observability Stack (1–2 pages)

**Author:** Yogesh  
**Date:** 12 Sep 2025  
**Repos:**  
- Infra (Terraform): https://github.com/YOGESHnp/air-max-270-infra  
- CI / App: https://github.com/YOGESHnp/air-max-270-landing  
- GitOps (K8s + Observability): https://github.com/YOGESHnp/air-max-270-gitops

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