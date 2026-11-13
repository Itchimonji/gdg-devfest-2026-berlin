# =========================================================================
# PROJECT OUTPUTS
# =========================================================================
output "project_id" {
  description = "The adapted GCP project ID used for bucket resources."
  value       = local.env_project_id
}

# =========================================================================
# BUCKET OUTPUTS
# =========================================================================
output "bucket_name" {
  description = "The name of the created Cloud Storage bucket."
  value       = module.bucket.name
}

output "bucket_url" {
  description = "The base URL of the bucket (useful for frontend/backend configurations)."
  value       = module.bucket.url
}

output "bucket" {
  description = "The created Cloud Storage bucket resource."
  value       = module.bucket.bucket
}

# =========================================================================
# SERVICE ACCOUNT OUTPUTS
# =========================================================================
output "service_account_email" {
  description = "The email address of the service account created to manage the bucket."
  value       = google_service_account.storage_manager.email
}

output "service_account_id" {
  description = "The fully-qualified ID of the service account."
  value       = google_service_account.storage_manager.id
}

output "service_account_name" {
  description = "The fully-qualified name of the service account."
  value       = google_service_account.storage_manager.name
}
