output "region" {
  description = "Region where resources were created."
  value       = local.default_region
}

output "project_id" {
  description = "The adapted GCP project ID where resources were created."
  value       = module.bucket.project_id
}

# =========================================================================
# BUCKET OUTPUTS
# =========================================================================
output "bucket_name" {
  description = "The name of the created Cloud Storage bucket."
  value       = module.bucket.bucket_name
}

output "bucket_url" {
  description = "The base URL of the bucket (useful for frontend/backend configurations)."
  value       = module.bucket.bucket_url
}

output "bucket_service_account_email" {
  description = "The email address of the service account created to manage the bucket."
  value       = module.bucket.service_account_email
}

output "bucket_service_account_id" {
  description = "The fully-qualified ID of the service account."
  value       = module.bucket.service_account_id
}

output "bucket_service_account_name" {
  description = "The fully-qualified name of the service account."
  value       = module.bucket.service_account_name
}

# =========================================================================
# SCHEDULED FUNCTION OUTPUTS
# =========================================================================
output "scheduler_job_name" {
  description = "The name of the Cloud Scheduler job."
  value       = module.cloud_function.scheduler_job_name
}

output "pubsub_topic_name" {
  description = "The Pub/Sub topic triggering the scheduled function."
  value       = module.cloud_function.pubsub_topic_name
}

output "cloud_function_name" {
  description = "The name of the deployed Cloud Function."
  value       = module.cloud_function.function_name
}

output "cloud_function_service_account_email" {
  description = "The service account email used by the Cloud Function."
  value       = module.cloud_function.service_account_email
}
