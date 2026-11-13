variable "enable_apis" {
  description = "Whether to automatically enable required Google Cloud APIs via Terraform."
  type        = bool
  default     = true
}

# Automatically enable required Google Cloud APIs before provisioning resources
resource "google_project_service" "required_services" {
  for_each = var.enable_apis ? toset([
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "pubsub.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
  ]) : toset([])

  project            = local.env_project_id
  service            = each.key
  disable_on_destroy = false
}
