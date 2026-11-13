variable "enable_apis" {
  description = "Whether to automatically enable required Google Cloud APIs via Terraform."
  type        = bool
  default     = true
}

# Automatically enable Google Cloud Storage API before provisioning bucket
resource "google_project_service" "storage_service" {
  count              = var.enable_apis ? 1 : 0
  project            = local.env_project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}
