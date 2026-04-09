terraform {
  backend "gcs" {
    # Backend configuration values are passed via -backend-config flag during init
    # Each environment has its own backend-config.hcl file with:
    # - bucket: The GCS bucket for state storage
    # - prefix: The path prefix for state files (e.g., dev/terraform, qa/terraform, prod/terraform)
    # Example usage:
    # terraform init -backend-config=backend-config.hcl
  }
}
