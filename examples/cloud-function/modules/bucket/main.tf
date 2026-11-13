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

module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 12.4"

  project_id       = local.env_project_id
  prefix           = "bkt-${local.clean_business_unit}-${var.env_short}"
  names            = [var.bucket_name_suffix]
  location         = var.region
  randomize_suffix = true

  versioning = {
    (var.bucket_name_suffix) = true
  }

  force_destroy = {
    (var.bucket_name_suffix) = true
  }

  depends_on = [
    google_project_service.storage_service
  ]
}
