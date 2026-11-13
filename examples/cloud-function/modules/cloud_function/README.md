# Scheduled Cloud Function Module

Reusable Terraform module wrapping the official Google Cloud Foundation Toolkit (CFT) [`terraform-google-modules/scheduled-function/google`](https://github.com/terraform-google-modules/terraform-google-scheduled-function) module.

## Architecture & Features

This module provisions an automated scheduled serverless pipeline:
1. **Automated API Enablement:** Uses `google_project_service` to automatically enable Cloud Functions, Cloud Scheduler, Pub/Sub, Cloud Build, Artifact Registry, and Storage APIs.
2. **Cloud Scheduler Job:** Fires on a configurable cron schedule (`job_schedule`).
3. **Cloud Pub/Sub Topic:** Receives the scheduled event (`top-${business_unit}-${env_short}`).
4. **Cloud Function:** Triggered by Pub/Sub message, executes Python code (`store_data`) to write data and assets into Cloud Storage.
5. **Least-Privilege IAM:** Automatically provisions a dedicated Service Account (`sa-${business_unit}-fn-${env_short}`) with scoped `roles/storage.objectUser` access limited strictly to the target destination bucket.

```text
 ┌──────────────────────┐     Pub/Sub      ┌──────────────────────┐     Trigger      ┌──────────────────────┐
 │ Cloud Scheduler Job  │ ───────────────> │  Cloud Pub/Sub Topic │ ───────────────> │    Cloud Function    │
 │ (e.g. 0 * * * *)     │                  │  top-...-dev         │                  │    fn-...-dev        │
 └──────────────────────┘                  └──────────────────────┘                  └──────────┬───────────┘
                                                                                                │
                                                                           roles/storage.objectUser
                                                                                                ▼
                                                                                     ┌──────────────────────┐
                                                                                     │ Cloud Storage Bucket │
                                                                                     │ bkt-...-dev-data     │
                                                                                     └──────────────────────┘
```

## ⚙️ Function Logic & Runtime Behavior (`function_source/main.py`)

When the function entry point (`store_data`) is executed via Pub/Sub:
1. **Payload Extraction:** Extracts and base64-decodes the payload published to the topic (e.g. message string or execution trigger).
2. **Metadata Generation:** Generates an ISO 8601 UTC timestamp and a pseudo-random run ID.
3. **Structured Telemetry Ingestion:** Uploads a formatted JSON telemetry record to `gs://${BUCKET_NAME}/records/${ENVIRONMENT}/${timestamp}-${record_id}.json` containing:
   - Run ID and execution timestamp
   - Environment and event metadata (`gdg-devfest-2026-berlin`)
   - Trigger source (`cloud-scheduler`)
4. **Visual Asset Generation:** Generates and uploads a vector graphic badge (`.svg`) to `gs://${BUCKET_NAME}/images/${ENVIRONMENT}/${timestamp}-${record_id}.svg`.
5. **Observability:** Logs the resulting Cloud Storage object paths to Cloud Logging for verification.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Core project name (e.g. `gdg-devfest-demo`) or full GCP project ID | `string` | n/a | yes |
| environment | Environment name (`development`, `production`) | `string` | n/a | yes |
| env\_short | Environment short code (`dev`, `prod`) | `string` | n/a | yes |
| business\_unit | Business unit identifier (`datacenter_1`) | `string` | n/a | yes |
| region | Google Cloud region | `string` | n/a | yes |
| bucket\_name | Name of the destination storage bucket where data will be stored | `string` | n/a | yes |
| job\_schedule | Cron schedule for the Cloud Scheduler job | `string` | `"0 * * * *"` | no |
| runtime | Function runtime environment | `string` | `"python311"` | no |
| entry\_point | Name of the function entry point in code | `string` | `"store_data"` | no |
| enable\_apis | Whether to automatically enable required Google Cloud APIs | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The adapted GCP project ID used for resources |
| scheduler\_job\_name | Name of the created Cloud Scheduler job |
| pubsub\_topic\_name | Name of the created Pub/Sub topic |
| function\_name | Name of the deployed Cloud Function |
| service\_account\_email | Service account email used by the Cloud Function |
| service\_account\_id | Fully-qualified ID of the service account |
| service\_account\_name | Fully-qualified resource name of the service account |

## 🧪 Testing

```bash
# 1. Trigger the Cloud Scheduler job
gcloud scheduler jobs run "<JOB_NAME>" --location="<REGION>" --project="<PROJECT_ID>"

# 2. Or publish directly to the Pub/Sub topic
gcloud pubsub topics publish "<TOPIC_NAME>" --message="Test message" --project="<PROJECT_ID>"

# 3. Verify files in Cloud Storage
gcloud storage ls --recursive "gs://<BUCKET_NAME>/"

# 4. Stream Cloud Function logs
gcloud functions logs read "<FUNCTION_NAME>" --region="<REGION>" --project="<PROJECT_ID>" --limit=25
```
