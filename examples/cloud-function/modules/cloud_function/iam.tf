data "google_project" "project" {
  project_id = local.env_project_id
}

# Explicitly provision the Cloud Functions Service Agent identity
resource "google_project_service_identity" "gcf_sa" {
  provider = google-beta
  project  = local.env_project_id
  service  = "cloudfunctions.googleapis.com"

  depends_on = [
    google_project_service.required_services
  ]
}

resource "google_service_account" "function_sa" {
  account_id   = "sa-${local.clean_business_unit}-fn-${var.env_short}"
  display_name = "Cloud Function SA (${var.environment})"
  description  = "Service account used by the scheduled Cloud Function to write data and assets into GCS"
  project      = local.env_project_id
}

# Grant the Cloud Function least-privilege permission to create/read objects in the destination bucket
resource "google_storage_bucket_iam_member" "function_bucket_writer" {
  bucket = var.bucket_name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant Artifact Registry Reader to Cloud Functions Service Agent (required to retrieve gcf-artifacts metadata)
resource "google_project_iam_member" "gcf_artifact_registry_reader" {
  project = local.env_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_project_service_identity.gcf_sa.email}"

  depends_on = [
    google_project_service.required_services
  ]
}

# Grant Artifact Registry Reader to the Cloud Function's dedicated service account
resource "google_project_iam_member" "function_sa_artifact_registry_reader" {
  project = local.env_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.function_sa.email}"

  depends_on = [
    google_project_service.required_services
  ]
}
