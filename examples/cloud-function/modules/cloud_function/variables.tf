variable "project_id" {
  description = "The core project name (e.g. datacenter_1) or full GCP project ID."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g. development, production)."
  type        = string
}

variable "env_short" {
  description = "The short environment code (e.g. dev, prod)."
  type        = string
}

variable "business_unit" {
  description = "The business unit identifier (e.g. datacenter_1)."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy the function to."
  type        = string
}

variable "bucket_name" {
  description = "The name of the destination Cloud Storage bucket where the function stores data."
  type        = string
}

variable "job_schedule" {
  description = "Cron schedule for the Cloud Scheduler job."
  type        = string
  default     = "0 * * * *"
}

variable "runtime" {
  description = "The runtime in which to run the function."
  type        = string
  default     = "python311"
}

variable "entry_point" {
  description = "The name of the function (as defined in source code) that will be executed."
  type        = string
  default     = "store_data"
}
