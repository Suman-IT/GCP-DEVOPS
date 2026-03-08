# GCP DevOps Hands‑on Project

This repository is a demonstration of a full DevOps workflow on Google Cloud Platform using free tier resources. It includes:

- **Terraform infrastructure** for multiple projects and shared networking
- **GKE clusters** in `dev`, `qa`, and `prod` projects
- **Artifact Registry** for container images
- A simple **Python web application** with Dockerfile and Helm chart
- **GitHub Actions** CI pipeline to build and push images
- **GitOps directory** for ArgoCD (one directory per environment)
- Support for **Secret Manager**, **Workload Identity**, **Cloud Logging/Monitoring** via Terraform modules

> ⚠️ You will need at least one billing-enabled GCP account per project. The free tier has limits; please delete resources when not needed.

---
## Architecture overview

```
Developer
   ↓
GitHub
   ↓
GitHub Actions CI (build, test)
   ↓
Container Build → Artifact Registry
   ↓
Terraform IaC (projects, networking, clusters, IAM, registry, secrets)
   ↓
GKE Deployment (Helm/ArgoCD)
   ↓
Monitoring + Logging (Stackdriver)
```

Projects:

1. `network` – host the Shared VPC
2. `dev` – dev cluster and resources
3. `qa` – QA cluster and resources
4. `prod` – production cluster and resources

All clusters attach to the same VPC subnets.

---
## Detailed Architecture

### Project Structure Overview

```
GCP-DEVOPS/
├── 📋 Documentation
│   ├── README.md                                    # Main documentation
│   └── FREE_TIER_SETUP_GUIDE.md                     # Free tier setup guide
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

### Complete Infrastructure Flow

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
    ┌────────────────────────────────────────────────────────┐
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

### Application Deployment Flow

```
STEP 1: CODE CHANGES → STEP 2: CI/CD BUILD → STEP 3: ARTIFACT REGISTRY
   ↓                      ↓                      ↓
App Code             Docker Image          Container Images
Dockerfile           GitHub Actions        (dev/qa/prod tags)
Helm Values          Build & Push              ↓
   │                    │                      │
   └────────────────────┴──────────────────────┘
                         ↓
            STEP 4: ARGOCD MONITORS & SYNCS
            ├─ Watches: gitops/{env}/values-{env}.yaml
            ├─ Watches: app/helm-chart/
            └─ Auto-syncs every 3 minutes
                         ↓
            STEP 5: KUBERNETES DEPLOYMENT
            ├─ Pulls image from Artifact Registry
            ├─ Starts Pod with Helm values
            ├─ Service exposes application
            └─ Workload Identity binds to GCP SA
```

---
## Getting started

1. **Create the GCP projects** (you can also manage them via Terraform).
   ```sh
   gcloud projects create my-network-project --name="Network"
   gcloud projects create my-dev-project     --name="Dev"
   gcloud projects create my-qa-project      --name="QA"
   gcloud projects create my-prod-project    --name="Prod"
   # enable billing for each and enable required APIs
   gcloud services enable compute.googleapis.com container.googleapis.com \
     artifactregistry.googleapis.com iam.googleapis.com servicenetworking.googleapis.com
   ```

2. **Initialize GitHub secrets**
   Add the following secrets to your repository for CI and Terraform workflows:
   - `GCP_PROJECT_DEV`, `GCP_PROJECT_QA`, `GCP_PROJECT_PROD` – corresponding project IDs
   - `GCP_NETWORK_PROJECT` – network project ID
   - `GCP_SA_KEY` – service account JSON key with sufficient permissions
   - `GITOPS_REPO` – URL of this repository (e.g. `https://github.com/you/org`)
   - `ARGOCD_SERVER` – ArgoCD API endpoint (e.g. `https://argocd.mycluster.example.com`)
   - `ARGOCD_TOKEN` – service account token or admin token for ArgoCD provider

2. **Configure Shared VPC**
   - In `my-network-project`, create a VPC and subnets (see `terraform/modules/network`).
   - Attach the service projects (`my-dev-project`, `my-qa-project`, `my-prod-project`) as service project attachments.

3. **Bootstrap Terraform**
   - Install Terraform 1.4+.
   - Initialize each environment directory:
     ```sh
     cd terraform/envs/dev
     terraform init
     terraform apply -var="project_id=my-dev-project" -var="network_project_id=my-network-project" \
       -var="node_service_account=my-node-sa@my-dev-project.iam.gserviceaccount.com" \
       -var="subnets=[{name=\"dev-subnet\", cidr=\"10.0.0.0/24\", region=\"us-central1\"}]"
     ```
   - Repeat for `qa` and `prod` directories with the corresponding IDs.

4. **Build and push the container**
   - Add repository secrets in GitHub: `GCP_PROJECT`, `GCP_SA_KEY` (JSON key), etc.
   - Commit code and push to `main`. GitHub Actions workflow at `.github/workflows/ci.yaml` will build and push the image.

5. **GitOps / ArgoCD**
   - Install ArgoCD in each cluster (or use one central ArgoCD instance to manage all envs).
   - Create ArgoCD `Application` manifests pointing to the directories under `gitops/dev`, `gitops/qa`, `gitops/prod`.
   - Promote by changing the image tag in the appropriate overlay or by creating PRs.

6. **Secrets & Workload Identity**
   - Use Terraform `google_secret_manager_secret` to create secrets.
   - Use the `iam` module to create service accounts and bind them to Kubernetes service accounts using workload identity.

7. **Monitoring / Logging**
   - GKE clusters are automatically integrated with Cloud Logging and Monitoring when the APIs are enabled.
   - Additional dashboards and alerting can be created manually or via Terraform.

---
## Directory structure

```text
GCP-DEVOPS/
├── app/                      # sample python app + dockerfile + helm chart
├── gitops/                   # gitops repo layout for ArgoCD
│   ├── dev/                 # kustomize patch for dev
│   ├── qa/
│   └── prod/
├── terraform/
│   ├── modules/
│   │   ├── network/
│   │   ├── gke/
│   │   ├── artifact_registry/
│   │   └── iam/
│   └── envs/
│       ├── dev/
│       ├── qa/
│       └── prod/
├── .github/workflows/ci.yaml # CI pipeline example
└── README.md
```

---
## Next steps & customization

- Add `google_project` resources to automate project creation.
- Extend the `iam` module to provision Workload Identity pools or additional roles.
- Create a more sophisticated Helm chart with config maps, secrets, etc.
- Use the `argocd` Terraform provider to register GitOps applications from within your IaC: see the new `terraform/modules/argocd` module and the example calls in each environment.
- A dedicated GitHub Actions workflow (`.github/workflows/terraform-deploy.yaml`) now applies Terraform across `dev`, `qa`, and `prod` whenever `terraform/**` changes.
- Implement promotion automation using GitHub Actions that updates the GitOps repo.
- Add Cloud Monitoring alert policies via Terraform.

Feel free to adapt and expand this template to suit your learning goals!
