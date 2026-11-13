# =========================================================================
# PROJECT OUTPUTS
# =========================================================================
output "project_id" {
  description = "The adapted GCP project ID used for function resources."
  value       = local.env_project_id
}

# =========================================================================
# SCHEDULED FUNCTION OUTPUTS
# =========================================================================
output "scheduler_job_name" {
  description = "The name of the Cloud Scheduler job created."
  value       = module.scheduled_function.name
}

output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic created to trigger the function."
  value       = module.scheduled_function.pubsub_topic_name
}

output "function_name" {
  description = "The name of the deployed Cloud Function."
  value       = "fn-${local.clean_business_unit}-${var.env_short}"
}

# =========================================================================
# SERVICE ACCOUNT OUTPUTS
# =========================================================================
output "service_account_email" {
  description = "The email address of the service account used by the Cloud Function."
  value       = google_service_account.function_sa.email
}

output "service_account_id" {
  description = "The fully-qualified ID of the service account."
  value       = google_service_account.function_sa.id
}

output "service_account_name" {
  description = "The fully-qualified name of the service account."
  value       = google_service_account.function_sa.name
}
