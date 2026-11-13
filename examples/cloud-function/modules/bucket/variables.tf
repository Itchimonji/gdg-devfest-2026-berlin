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
  description = "The Google Cloud region to host the bucket in."
  type        = string
}

variable "bucket_name_suffix" {
  description = "The suffix for the storage bucket name."
  type        = string
  default     = "data"
}
