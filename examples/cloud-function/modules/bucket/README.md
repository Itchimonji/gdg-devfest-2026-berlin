# Cloud Storage Bucket Module

Reusable Terraform module wrapping the official Google Cloud Foundation Toolkit (CFT) `terraform-google-modules/cloud-storage/google` module.

## Features

- Enforces standardized naming conventions: `bkt-${business_unit}-${env_short}-${suffix}-${random_hex}`
- Uniform Bucket Level Access (UBLA) enabled for enhanced security
- Object versioning enabled by default
- Dedicated Storage Manager service account with least-privilege IAM binding (`roles/storage.objectUser`)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | GCP project ID where the bucket will be created | `string` | n/a | yes |
| environment | Environment name (`development`, `production`) | `string` | n/a | yes |
| env\_short | Environment short code (`dev`, `prod`) | `string` | n/a | yes |
| business\_unit | Business unit identifier (`datacenter_1`) | `string` | n/a | yes |
| region | Google Cloud region | `string` | n/a | yes |
| bucket\_name\_suffix | Suffix for the storage bucket name | `string` | `"data"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name | The generated globally unique name of the bucket |
| bucket\_url | Base URL of the bucket (`gs://...`) |
| bucket | The full bucket resource object |
| service\_account\_email | The email address of the bucket storage manager service account |
| service\_account\_id | The fully-qualified ID of the service account |
| service\_account\_name | The fully-qualified resource name of the service account |
