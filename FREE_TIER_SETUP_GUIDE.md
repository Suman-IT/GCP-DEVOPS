# GCP Free Tier Setup Guide for GCP-DEVOPS

This guide explains how to set up and deploy the GCP-DEVOPS infrastructure on a GCP **Free Tier account** (without an Organization ID).

## Key Differences: Free Tier vs Organization Accounts

| Feature | Free Tier | Organization Account |
|---------|-----------|----------------------|
| **org_id** | Not required (leave empty) | Required (provide org ID) |
| **billing_account** | Optional (free tier) | Required for billing |
| **create_project** | Set to `false` (project exists) | Can be `true` or `false` |
| **Project Creation** | Manual (via GCP Console) | Automatic via Terraform |
| **Shared VPC** | Yes, supported | Yes, supported |

## Prerequisites for Free Tier Accounts

### 1. Create GCP Projects Manually
Since you don't have an organization, you must create GCP projects manually:

1. Go to [GCP Console](https://console.cloud.google.com)
2. Click the project dropdown at the top
3. Click "NEW PROJECT"
4. Create the following projects:
   - **Common/Network Project**: For the shared VPC host (e.g., `my-network-project`)
   - **Dev Project**: For development environment (e.g., `my-dev-project`)
   - **QA Project**: For QA environment (e.g., `my-qa-project`)
   - **Prod Project**: For production environment (e.g., `my-prod-project`)

5. Note down the **Project IDs** (not the display names) for each project:
   - Network Project ID: `______________________`
   - Dev Project ID: `______________________`
   - QA Project ID: `______________________`
   - Prod Project ID: `______________________`

### 2. Enable Billing for Projects
1. Each project needs billing enabled
2. Go to **Billing** → Link each project to your billing account
3. (Note: Free tier gives you $300 credit)

### 3. Install Required Tools
```bash
# Install Terraform
# https://www.terraform.io/downloads

# Verify Terraform installation
terraform --version

# Install Google Cloud CLI
# https://cloud.google.com/sdk/docs/install

# Verify gcloud installation
gcloud --version
```

### 4. Authenticate with GCP
```bash
# Login to GCP
gcloud auth login

# Set your default project (use the network/common project)
gcloud config set project your-network-project-id
```

## Step 1: Bootstrap Infrastructure (No org_id)

### 1.1 Update Bootstrap Configuration
Edit `terraform/bootstrap/terraform.tfvars`:

```hcl
# IMPORTANT: For Free Tier, use these settings:
project_id        = "your-common-project-id"    # Use your manually-created project ID
project_number    = 123456789012                # Find this in GCP Console → Project Settings
region            = "us-central1"
org_id            = ""                           # LEAVE EMPTY FOR FREE TIER
billing_account   = ""                           # LEAVE EMPTY FOR FREE TIER
github_org        = "your-github-org"
github_repo       = "GCP-DEVOPS"
terraform_sa_name = "terraform-sa"
state_bucket_name = "gcp-devops-terraform-state-${random-suffix}"
create_project    = false                       # MUST BE FALSE (project already exists)
```

**How to find project_number:**
1. Go to GCP Console
2. Select your project
3. Click the **Project Settings** icon (⚙️)
4. Look for "Project number" field

### 1.2 Deploy Bootstrap Infrastructure
```bash
cd terraform/bootstrap

# Initialize Terraform
terraform init

# Preview changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars
```

**What Bootstrap Creates:**
- Terraform service account (`terraform-sa`)
- Workload Identity Pool for GitHub Actions
- GCS bucket for Terraform state
- Necessary IAM roles and permissions
- **Does NOT create a project** (you already created it manually)

### 1.3 Capture Bootstrap Outputs
After successful apply, run:
```bash
terraform output
```

You'll see:
- `terraform_sa_email`: Service account email
- `workload_identity_provider_id`: WIF provider path

**Save these values!** You'll need them for GitHub Actions (optional).

---

## Step 2: Deploy Common Infrastructure (Shared VPC Host)

This creates the shared network that all environments will use.

### 2.1 Update Common Configuration
Edit `terraform/common/terraform.tfvars`:

```hcl
# Use your manually-created network project
network_project_id = "your-network-project-id"
region             = "us-central1"
network_name       = "shared-vpc"
github_org         = "your-github-org"
github_repo        = "GCP-DEVOPS"

subnets = [
  {
    name   = "subnet-01"
    cidr   = "10.0.0.0/24"
    region = "us-central1"
  },
  {
    name   = "subnet-02"
    cidr   = "10.1.0.0/24"
    region = "us-east1"
  }
]
```

### 2.2 Deploy Common Infrastructure
```bash
cd terraform/common

# Initialize Terraform
terraform init

# Preview changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars
```

**What Common Creates:**
- Shared VPC Network (host mode enabled)
- Subnets for GKE clusters
- GKE node service account with logging/monitoring roles

### 2.3 Capture Common Outputs
After successful apply:
```bash
terraform output
```

Save these outputs (you'll use them for environment deployments):
- `network_name`: Network name
- `network_self_link`: Network path
- `subnets`: Subnet details
- `host_project_id`: Your network project ID

---

## Step 3: Deploy Environment-Specific Resources

Deploy dev, qa, and prod environments that attach to the shared VPC.

### 3.1 Update Environment Configuration (Dev)

Edit `terraform/envs/dev/terraform.tfvars`:

```hcl
# Free Tier Configuration
environment                 = "dev"
project_id                   = "your-dev-project-id"        # Your manually-created project
region                       = "us-central1"
org_id                       = ""                            # LEAVE EMPTY
billing_account              = ""                            # LEAVE EMPTY
artifact_repo_id             = "dev-app-repo"
cluster_name                 = "dev-cluster"

# Get these values from common output or GCP Console
network_self_link            = "projects/your-network-project-id/global/networks/shared-vpc"
subnet_self_link             = "projects/your-network-project-id/regions/us-central1/subnetworks/subnet-01"
node_service_account_email   = "gke-node-sa@your-network-project-id.iam.gserviceaccount.com"

# GitOps configuration
gitops_repo_url              = "https://github.com/your-org/your-repo.git"
gitops_revision              = "main"

# Shared VPC configuration
host_project_id              = "your-network-project-id"
service_project_number       = 123456789012                  # Dev project number (find in GCP Console)

# Free Tier: Don't create new project
create_project               = false
```

### 3.2 Deploy Dev Environment
```bash
cd terraform/envs

# Initialize (first time only)
terraform init

# Preview
terraform plan -var-file=dev/terraform.tfvars

# Apply
terraform apply -var-file=dev/terraform.tfvars
```

### 3.3 Update and Deploy QA Environment

Edit `terraform/envs/qa/terraform.tfvars` (similar to dev but with):
```hcl
environment          = "qa"
project_id           = "your-qa-project-id"
cluster_name         = "qa-cluster"
artifact_repo_id     = "qa-app-repo"
service_project_number = 123456789013  # QA project number
```

Deploy:
```bash
terraform plan -var-file=qa/terraform.tfvars
terraform apply -var-file=qa/terraform.tfvars
```

### 3.4 Update and Deploy Prod Environment

Edit `terraform/envs/prod/terraform.tfvars` (similar to dev but with):
```hcl
environment          = "prod"
project_id           = "your-prod-project-id"
cluster_name         = "prod-cluster"
artifact_repo_id     = "prod-app-repo"
service_project_number = 123456789014  # Prod project number
```

Deploy:
```bash
terraform plan -var-file=prod/terraform.tfvars
terraform apply -var-file=prod/terraform.tfvars
```

---

## Finding Project Numbers

To find the project number for each project:

```bash
# Method 1: Using gcloud
gcloud projects list --format="table(projectId,projectNumber)"

# Method 2: Using GCP Console
# 1. Go to each project
# 2. Click the ⚙️ Settings icon
# 3. Look for "Project number"
```

---

## Verification Checklist

After deployment, verify everything is working:

### ✓ Bootstrap Verification
```bash
cd terraform/bootstrap

# Check that WIF provider exists
terraform output workload_identity_provider_id

# Check that service account exists
terraform output terraform_sa_email

# Verify state bucket
gsutil ls gs://gcp-devops-terraform-state-*
```

### ✓ Common Infrastructure Verification
```bash
cd terraform/common

# Check VPC was created
gcloud compute networks list --project=your-network-project-id

# Check subnets
gcloud compute networks subnets list --network=shared-vpc --project=your-network-project-id

# Check shared VPC host is enabled
gcloud compute shared-vpc organizations describe your-network-project-id
```

### ✓ Environment Verification
```bash
# For each environment (dev/qa/prod):

# Check Shared VPC attachment
gcloud compute shared-vpc associated-projects list your-network-project-id

# Check GKE cluster exists
gcloud container clusters list --project=your-env-project-id

# Check Artifact Registry
gcloud artifacts repositories list --project=your-env-project-id
```

---

## Cleanup (If Needed)

To remove all resources:

```bash
# Deploy in reverse order (envs first, then common, then bootstrap)

# Destroy environments
cd terraform/envs
terraform destroy -var-file=dev/terraform.tfvars
terraform destroy -var-file=qa/terraform.tfvars
terraform destroy -var-file=prod/terraform.tfvars

# Destroy common
cd terraform/common
terraform destroy -var-file=terraform.tfvars

# Destroy bootstrap
cd terraform/bootstrap
terraform destroy -var-file=terraform.tfvars

# Delete projects manually in GCP Console
# (Only GCP Console can delete projects)
```

---

## Common Issues with Free Tier

### Error: "Organization not found"
- **Cause**: `org_id` is set instead of empty
- **Fix**: Set `org_id = ""` in all terraform.tfvars files

### Error: "Project cannot be created"
- **Cause**: Trying to create a project with `create_project = true` but no `org_id`
- **Fix**: Set `create_project = false` and create projects manually first

### Error: "Billing account not found"
- **Cause**: `billing_account` is set but not valid
- **Fix**: Set `billing_account = ""` for free tier, enable billing on projects manually

### Error: "Cannot find shared VPC host"
- **Cause**: Network was created in different project or uses wrong project_id
- **Fix**: Verify `network_self_link` matches the actual network created in `common/`

### Error: "Service account doesn't have permission"
- **Cause**: Bootstrap didn't grant proper IAM roles
- **Fix**: Run bootstrap with `create_project = false` so it only enables services

---

## Next Steps

Once infrastructure is deployed:

1. **Connect to GKE clusters**:
   ```bash
   gcloud container clusters get-credentials dev-cluster --zone us-central1-a --project your-dev-project-id
   ```

2. **Install ArgoCD** (if using GitOps):
   - Follow [ArgoCD Installation Guide](https://argo-cd.readthedocs.io/en/stable/getting_started/)

3. **Deploy Applications**:
   - Use the provided Helm charts in `app/helm-chart/`
   - Configure ArgoCD to watch your git repository

4. **Set up GitHub Actions** (optional):
   - Add `WIF_PROVIDER` and `TERRAFORM_SA_EMAIL` as GitHub secrets
   - GitHub workflows can then automatically deploy infrastructure

---

## Support & Troubleshooting

- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/google/latest
- **GCP Free Tier Docs**: https://cloud.google.com/free
- **Shared VPC Guide**: https://cloud.google.com/vpc/docs/shared-vpc
- **GKE Setup**: https://cloud.google.com/kubernetes-engine/docs/quickstart
