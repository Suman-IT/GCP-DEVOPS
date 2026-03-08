# Terraform GCP DevOps Infrastructure

This repository contains Terraform configurations for deploying a complete GCP DevOps infrastructure with GitOps using ArgoCD.

## 📌 Using GCP Free Tier?

If you're using a **GCP Free Tier account** (without an Organization ID), please follow the **[FREE_TIER_SETUP_GUIDE.md](../FREE_TIER_SETUP_GUIDE.md)** instead. It provides:
- How to set up without `org_id`
- Manual project creation instructions
- Step-by-step configuration for free tier accounts
- Troubleshooting common free tier issues

---

## Architecture

### Project Structure Overview

```
GCP-DEVOPS/
├── 📋 Documentation
│   ├── README.md                                    # Main documentation
│   ├── FREE_TIER_SETUP_GUIDE.md                     # Free tier instructions
│   ├── FREE_TIER_IMPLEMENTATION.md                  # Implementation details
│   └── FREE_TIER_VERIFICATION.md                    # Verification checklist
│
├── 🐳 Application & Containers
│   ├── app/
│   │   ├── main.py                                  # Python application
│   │   ├── Dockerfile                               # Container definition
│   │   ├── requirements.txt                         # Dependencies
│   │   └── helm-chart/                              # K8s Helm charts
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           └── _helpers.tpl
│
├── 🔄 GitOps Configuration
│   └── gitops/                                       # ArgoCD values
│       ├── dev/values-dev.yaml
│       ├── qa/values-qa.yaml
│       └── prod/values-prod.yaml
│
└── 🏗️ Infrastructure as Code
    └── terraform/
        ├── bootstrap/                               # Initial setup (manual)
        ├── common/                                  # Shared resources
        ├── envs/                                    # Environment configs
        │   ├── dev/
        │   ├── qa/
        │   └── prod/
        └── modules/                                 # Reusable components
            ├── projects/
            ├── network/
            ├── gke/
            ├── iam/
            ├── artifact_registry/
            ├── argocd/
            └── shared_vpc_attachment/
```

### Shared VPC Design
The infrastructure uses Google Cloud's **Shared VPC** for centralized network management:
- **Host Project** (Common): Contains the VPC network and subnets
- **Service Projects** (Dev, QA, Prod): Environment-specific projects that consume the shared network

### High-Level Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                GITHUB REPOSITORY                              │
│  ├─ Application Code (Python/Flask) → Dockerfile → Container Image          │
│  ├─ Helm Charts (app/helm-chart/)                                           │
│  ├─ Terraform IaC (terraform/)                                              │
│  └─ GitOps Config (gitops/{dev,qa,prod}/)                                   │
└────────────────────────┬───────────────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    CI/CD PIPELINE  TERRAFORM WORKFLOW  ARGOCD SYNC
    (GitHub Actions) (Bootstrap→Common  (Pull-based
         │            →Envs)            Deployment)
         │               │               │
         └───────────────┼───────────────┘
                         │
    ┌────────────────────────────────────────────────────┐
    │         GCP (Google Cloud Platform)                │
    │                                                    │
    │  ┌──────────────────────────────────────────────┐ │
    │  │   BOOTSTRAP (One-time, Manual)               │ │
    │  │  [GCP Project | SA | WIF | State Bucket]    │ │
    │  └──────────────────────────────────────────────┘ │
    │                      │                            │
    │                      ↓                            │
    │  ┌──────────────────────────────────────────────┐ │
    │  │  COMMON (Shared VPC Host Project)            │ │
    │  │  ┌────────────────────────────────────────┐  │ │
    │  │  │  Shared VPC Network (10.0.0.0/24)     │  │ │
    │  │  │  - Subnets (us-central1, us-east1)   │  │ │
    │  │  │  - GKE Node SA                        │  │ │
    │  │  └────────────────────────────────────────┘  │ │
    │  └──────────────────────────────────────────────┘ │
    │           │              │              │        │
    │           ↓              ↓              ↓        │
    │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │
    │  │  DEV PROJECT │ │  QA PROJECT  │ │ PROD PROJECT │ │
    │  │              │ │              │ │              │ │
    │  │ [Attach VPC] │ │ [Attach VPC] │ │ [Attach VPC] │ │
    │  │              │ │              │ │              │ │
    │  │ ┌──────────┐ │ │ ┌──────────┐ │ │ ┌──────────┐ │ │
    │  │ │GKE Dev  │ │ │ │GKE QA    │ │ │ │GKE Prod │ │ │
    │  │ │Cluster  │ │ │ │Cluster   │ │ │ │Cluster  │ │ │
    │  │ └──────────┘ │ │ └──────────┘ │ │ └──────────┘ │ │
    │  │              │ │              │ │              │ │
    │  │ ┌──────────┐ │ │ ┌──────────┐ │ │ ┌──────────┐ │ │
    │  │ │Artifact  │ │ │ │Artifact  │ │ │ │Artifact  │ │ │
    │  │ │Registry  │ │ │ │Registry  │ │ │ │Registry  │ │ │
    │  │ └──────────┘ │ │ └──────────┘ │ │ └──────────┘ │ │
    │  │              │ │              │ │              │ │
    │  │ ┌──────────┐ │ │ ┌──────────┐ │ │ ┌──────────┐ │ │
    │  │ │ArgoCD    │ │ │ │ArgoCD    │ │ │ │ArgoCD    │ │ │
    │  │ │App (Dev) │ │ │ │App (QA)  │ │ │ │App (Prod)│ │ │
    │  │ └──────────┘ │ │ └──────────┘ │ │ └──────────┘ │ │
    │  └──────────────┘ └──────────────┘ └──────────────┘ │
    │         │              │              │              │
    │         └──────────────┴──────────────┘              │
    │                      │                              │
    │                      ↓                              │
    │         ┌──────────────────────────┐               │
    │         │ GitOps (ArgoCD Sync)     │               │
    │         │ Helm Values (values-x.yaml) │            │
    │         │ Deployment Management    │               │
    │         └──────────────────────────┘               │
    │                                                    │
    └────────────────────────────────────────────────────┘
```

### Components

The infrastructure is organized into the following components:

### Bootstrap Infrastructure (`bootstrap/`)
**Manual, one-time deployment** (NOT automated via workflow). Resources that must exist before any other Terraform can run:
- **Common Project**: GCP project where shared services live
- **Service Account**: `terraform-sa` used by GitHub Actions
- **State Bucket**: GCS bucket for Terraform remote state
- **Workload Identity Pool & Provider**: Allow GitHub Actions to assume `terraform-sa`

⚠️ **Important**: Bootstrap must be run locally first because the GitHub Actions workflows depend on the WIF and service account that bootstrap creates.

### Common Infrastructure (`common/`)
**Shared VPC Host Project** containing resources used across all environments:
- **Shared VPC Network**: Host network for all service projects
- **Subnets**: Shared subnets accessible to service projects
- **IAM Service Accounts**: GKE node service account with appropriate roles

### Environment-Specific Deployments (`envs/`)
**Service Projects** that consume the shared VPC. A single Terraform configuration deploys resources for each environment:
- **Environment Project**: Separate GCP project (dev, qa, prod)
- **Shared VPC Attachment**: Attaches this project to the shared VPC host
- **GKE Cluster**: Kubernetes cluster using shared VPC subnets
- **Artifact Registry**: Container registry for the environment
- **ArgoCD Application**: GitOps deployment configuration

## Authentication

This project uses **Workload Identity Federation (WIF)** for secure authentication from GitHub Actions to GCP, eliminating the need for service account keys.

### Required GitHub Secrets
- `WIF_PROVIDER`: Workload Identity Provider path (output from bootstrap)
- `TERRAFORM_SA_EMAIL`: Terraform service account email (output from bootstrap)

Secrets such as `NETWORK_PROJECT_ID`, `STATE_BUCKET`, etc., should also be populated from bootstrap outputs to be consumed by later workflows.

## Deployment Order

### 1. Bootstrap (Manual, One-Time Only)
The bootstrap infrastructure must be deployed **locally first** because GitHub Actions authentication (WIF) depends on resources created by bootstrap. Follow this sequence:

```bash
cd terraform/bootstrap
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

After bootstrap completes successfully, capture the outputs and add them to GitHub Actions secrets:
- `WIF_PROVIDER`: workload_identity_provider_id output
- `TERRAFORM_SA_EMAIL`: terraform_sa_email output
- `GCP_PROJECT`: project_id output

**Creates:**
- GCP Project for shared resources (network, IAM)
- Terraform service account with appropriate permissions
- Workload Identity Federation provider for GitHub Actions
- GCS bucket for Terraform remote state

### 2. Deploy Shared VPC Host Infrastructure (Common)
Creates the shared VPC network and enables Shared VPC host mode in the common project:

```bash
cd terraform/common
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

GitHub Actions workflow `terraform-common.yaml` will automatically run on updates to `terraform/common/`.

**Creates:**
- VPC Network (Shared VPC host mode enabled)
- Subnets in specified regions
- GKE node service account in host project
- Outputs network_self_link, subnets, host_project_id (consumed by environments)

### 3. Deploy Environment-Specific Resources (Service Projects)
Each environment (dev/qa/prod) is a separate GCP project that **attaches to the shared VPC host**. Deploy in sequence:

```bash
cd terraform/envs

# Deploy dev environment
terraform init
terraform plan -var-file=dev/terraform.tfvars
terraform apply -var-file=dev/terraform.tfvars

# Deploy qa environment
terraform plan -var-file=qa/terraform.tfvars
terraform apply -var-file=qa/terraform.tfvars

# Deploy prod environment
terraform plan -var-file=prod/terraform.tfvars
terraform apply -var-file=prod/terraform.tfvars
```

GitHub Actions workflow `terraform-deploy.yaml` will automatically run on updates to `terraform/envs/` using the matrix strategy for all three environments.

**Creates (per environment):**
- GCP Service Project
- **Shared VPC Attachment**: Attaches service project to host VPC with appropriate IAM bindings
- GKE Cluster: Uses subnets from shared VPC host project
- Artifact Registry: Container repository
- ArgoCD Application: GitOps configuration

## Configuration Files

- `envs/main.tf`: Single Terraform configuration for all environments
- `envs/variables.tf`: Variable declarations (no defaults)
- `envs/{env}/terraform.tfvars`: Environment-specific variable values

## Module Dependencies and Structure

### Dependency Flow
```
Bootstrap (manual) 
  ↓ (creates WIF, SA, state bucket)
Common (applies first)
  ↓ (outputs: network_self_link, host_project_id, subnets)
Environment-Specific (dev, qa, prod) (apply sequentially)
  ↓ (each attaches to shared VPC host)
ArgoCD Applications (deployed via Terraform)
```

### Terraform Module Dependency Diagram

```
terraform/
├── bootstrap/                         ← Deploy FIRST (Manual)
│   ├── Creates: GCP Project
│   ├── Creates: Terraform Service Account
│   ├── Creates: Workload Identity Federation
│   ├── Creates: GCS State Bucket
│   └── Outputs: WIF Provider ID, SA Email, State Bucket
│
├── common/                            ← Deploy SECOND (Depends on Bootstrap)
│   ├── depends_on: Bootstrap outputs (via GitHub secrets)
│   ├── modules/network/
│   │   └── Creates: Shared VPC Host, Subnets
│   ├── modules/iam/
│   │   └── Creates: GKE Node Service Account
│   └── Outputs: Network Link, Subnets, Host Project ID
│
└── envs/                              ← Deploy THIRD (Depends on Common)
    ├── main.tf                        ← Single config for all envs
    ├── modules/projects/
    │   └── Creates: GCP Project (per env)
    ├── modules/shared_vpc_attachment/
    │   └── Attaches service project to host VPC
    ├── modules/gke/
    │   ├── depends_on: shared_vpc_attachment
    │   └── Creates: GKE Cluster (uses shared VPC)
    ├── modules/artifact_registry/
    │   └── Creates: Container Registry (per env)
    ├── modules/argocd/
    │   └── Creates: ArgoCD Application (per env)
    │
    ├── dev/terraform.tfvars           ← Development values
    ├── qa/terraform.tfvars            ← QA values
    └── prod/terraform.tfvars          ← Production values
```

### Key Modules
- **bootstrap/**
  - No dependencies
  - Creates: Project, Service Account, WIF, state bucket

- **common/**
  - Depends on bootstrap outputs via GitHub secrets
  - Creates: Shared VPC host project, network, subnets, GKE node SA
  - Outputs: network_self_link, subnet_self_links, host_project_id (used by envs/)

- **modules/network/**
  - Supports both standalone and shared VPC host mode (via enable_shared_vpc_host variable)
  - Created in common/ with enable_shared_vpc_host=true

- **modules/shared_vpc_attachment/** (NEW)
  - Attaches service projects to host VPC
  - Grants IAM permissions (networkUser, securityAdmin)
  - Used by each environment in envs/main.tf

- **modules/gke/**
  - Uses already-attached shared VPC subnets from host project
  - Depends on: shared_vpc_attachment module (via depends_on)

- **envs/**
  - References common outputs from terraform.tfvars
  - Creates shared_vpc_attachment for each environment
  - Uses GKE with proper network configuration

## Prerequisites

- GCP Organization with billing account
- ArgoCD installed in your cluster (for ArgoCD module)
- Workload Identity Pool and Provider configured
- Appropriate IAM permissions for Terraform service account

## Notes

- **Shared VPC Architecture**: Network resources are centralized in the common project (host project). Each environment project (dev/qa/prod) is a service project that attaches to the host and shares the VPC network and subnets.
- **Host Project**: `terraform/common/` creates the VPC host project with shared subnets that all service projects consume.
- **Service Projects**: `terraform/envs/` creates separate GCP projects for each environment that attach to the shared VPC via the shared_vpc_attachment module.
- **Network Sharing**: All GKE clusters across environments run on shared VPC subnets from the host project, enabling cross-environment networking when needed.
- **Terraform State**: Each deployment tier has its own remote state bucket with separate locking to prevent conflicts.
- **ArgoCD Applications**: Configured to deploy applications from the gitops/ directory with environment-specific Helm values in `gitops/<env>/values-<env>.yaml`.

---

## Application Deployment Flow (GitOps)

### Complete Deployment Pipeline

```
┌────────────────────────────────────────────────────────────────────────┐
│ STEP 1: APPLICATION CODE CHANGES                                       │
│ ┌──────────────────────────────────────────────────────────────────┐  │
│ │ Developer commits to main branch:                                 │  │
│ │ ├─ app/main.py (application code)                               │  │
│ │ ├─ app/Dockerfile (container definition)                        │  │
│ │ └─ gitops/{env}/values-{env}.yaml (Helm values)                │  │
│ └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────────────────┐
│ STEP 2: CI/CD PIPELINE (GitHub Actions)                               │
│ ┌──────────────────────────────────────────────────────────────────┐  │
│ │ ✓ Build Docker image from Dockerfile                           │  │
│ │ ✓ Push image to Artifact Registry                              │  │
│ │   (Tag: dev, qa, prod based on branch)                         │  │
│ │ ✓ Update gitops/{env}/values-{env}.yaml with image tag        │  │
│ └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────────────────┐
│ STEP 3: ARTIFACT REGISTRY (Container Images)                          │
│ ┌──────────────────────────────────────────────────────────────────┐  │
│ │ Artifact Registry (per-environment):                             │  │
│ │ ├─ dev-app-repo/demo-app:dev                                    │  │
│ │ ├─ qa-app-repo/demo-app:qa                                      │  │
│ │ └─ prod-app-repo/demo-app:v1.0.0                               │  │
│ └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────────────────┐
│ STEP 4: ARGOCD CONTINUOUS RECONCILIATION                              │
│ ┌──────────────────────────────────────────────────────────────────┐  │
│ │ ArgoCD (per environment) monitors:                               │  │
│ │ ├─ GitHub Repo: gitops/{env}/values-{env}.yaml                 │  │
│ │ ├─ Helm Chart: app/helm-chart/                                  │  │
│ │ └─ Polling Interval: Every 3 minutes (or on-push webhook)      │  │
│ │                                                                  │  │
│ │ When changes detected:                                           │  │
│ │ ✓ Fetches latest values-{env}.yaml from GitHub                 │  │
│ │ ✓ Merges with Helm chart defaults                              │  │
│ │ ✓ Syncs Kubernetes deployment                                   │  │
│ └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────────────────┐
│ STEP 5: KUBERNETES DEPLOYMENT (GKE)                                    │
│ ┌──────────────────────────────────────────────────────────────────┐  │
│ │ GKE Cluster (per environment):                                   │  │
│ │                                                                   │  │
│ │ ├─ Pod Deployment:                                              │  │
│ │ │  ├─ Pulls image from Artifact Registry                       │  │
│ │ │  ├─ Starts container on node                                 │  │
│ │ │  └─ Listens on port 8080                                     │  │
│ │ │                                                                │  │
│ │ ├─ Service (ClusterIP):                                         │  │
│ │ │  └─ Exposes pods on port 8080                                │  │
│ │ │                                                                │  │
│ │ ├─ Workload Identity:                                           │  │
│ │ │  └─ Binds K8s SA to GCP SA for secure access               │  │
│ │ │                                                                │  │
│ │ └─ Networking:                                                  │  │
│ │    └─ Uses shared VPC subnet from host project                 │  │
│ └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────────────────┘
                         │
                         ↓
            ┌────────────────────────────┐
            │  APPLICATION RUNNING       │
            │  Python Flask App          │
            │  Accessible to users       │
            └────────────────────────────┘
```

### Key Configuration Files in GitOps Flow

| File | Purpose | Updated By |
|------|---------|------------|
| `app/main.py` | Application source code | Developer |
| `app/Dockerfile` | Container build definition | Developer |
| `app/helm-chart/Chart.yaml` | Helm chart metadata | Helm maintainer |
| `app/helm-chart/values.yaml` | Default Helm values | Helm maintainer |
| `gitops/dev/values-dev.yaml` | Dev environment overrides | CI/CD (auto) + Manual |
| `gitops/qa/values-qa.yaml` | QA environment overrides | CI/CD (auto) + Manual |
| `gitops/prod/values-prod.yaml` | Prod environment overrides | Manual (prod only) |

### Multi-Environment Deployment Example

**Development Environment:**
```yaml
# gitops/dev/values-dev.yaml
replicaCount: 1
image:
  repository: gcr.io/dev-project/demo-app
  tag: "dev"  # Updated by CI/CD on every push
resources:
  limits: {cpu: 50m, memory: 64Mi}
```

**QA Environment:**
```yaml
# gitops/qa/values-qa.yaml
replicaCount: 2
image:
  repository: gcr.io/qa-project/demo-app
  tag: "qa"  # Updated by CI/CD on every push
resources:
  limits: {cpu: 100m, memory: 128Mi}
```

**Production Environment:**
```yaml
# gitops/prod/values-prod.yaml
replicaCount: 3
image:
  repository: gcr.io/prod-project/demo-app
  tag: "v1.0.0"  # Manual semantic versioning
resources:
  limits: {cpu: 500m, memory: 512Mi}
```

### GitOps Benefits

- **Declarative**: Desired state defined in Git
- **Versioned**: All changes tracked and auditable
- **Automated**: ArgoCD syncs automatically
- **Reproducible**: Exact same deployment across environments
- **Rollback**: Easy rollback by reverting Git commit
- **Multi-Environment**: Different values per env, same Helm chart