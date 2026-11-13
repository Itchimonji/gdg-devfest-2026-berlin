resource "google_service_account" "storage_manager" {
  account_id   = "sa-${local.clean_business_unit}-bkt-${var.env_short}"
  display_name = "Storage Manager SA (${var.environment})"
  description  = "Service account used for managing storage bucket contents in ${var.environment}"
  project      = local.env_project_id
}

resource "google_storage_bucket_iam_member" "sa_bucket_access" {
  bucket = module.bucket.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.storage_manager.email}"
}
