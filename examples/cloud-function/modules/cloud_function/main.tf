locals {
  clean_business_unit = replace(var.business_unit, "_", "-")
  clean_project_id    = replace(var.project_id, "_", "-")

  # Adapt core project name (e.g. "gdg-devfest-demo" -> "gdg-devfest-demo-dev")
  env_project_id = (
    endswith(local.clean_project_id, "-${var.env_short}")
    ? local.clean_project_id
    : "${local.clean_project_id}-${var.env_short}"
  )
}

module "scheduled_function" {
  source  = "terraform-google-modules/scheduled-function/google"
  version = "~> 6.0"

  project_id                     = local.env_project_id
  region                         = var.region
  job_name                       = "job-${local.clean_business_unit}-${var.env_short}"
  job_schedule                   = var.job_schedule
  topic_name                     = "top-${local.clean_business_unit}-${var.env_short}"
  function_name                  = "fn-${local.clean_business_unit}-${var.env_short}"
  function_entry_point           = var.entry_point
  function_source_directory      = "${path.module}/function_source"
  function_runtime               = var.runtime
  function_service_account_email = google_service_account.function_sa.email

  function_environment_variables = {
    BUCKET_NAME   = var.bucket_name
    ENVIRONMENT   = var.environment
    BUSINESS_UNIT = var.business_unit
  }

  depends_on = [
    google_project_service.required_services,
    google_project_iam_member.gcf_artifact_registry_reader,
    google_project_iam_member.function_sa_artifact_registry_reader,
  ]
}
