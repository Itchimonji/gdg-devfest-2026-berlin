locals {
  # Core project name: adapted by modules to "gdg-devfest-demo-dev"
  project_id        = var.project_id != null ? var.project_id : "gdg-devfest-demo"
  business_unit     = "datacenter_1"
  environment       = "development"
  environment_short = "dev"
  default_region    = "europe-west3"
}

module "bucket" {
  source = "../../modules/bucket"

  project_id    = local.project_id
  environment   = local.environment
  business_unit = local.business_unit
  env_short     = local.environment_short
  region        = local.default_region
}

module "cloud_function" {
  source = "../../modules/cloud_function"

  project_id    = local.project_id
  environment   = local.environment
  business_unit = local.business_unit
  env_short     = local.environment_short
  region        = local.default_region
  bucket_name   = module.bucket.bucket_name
}
