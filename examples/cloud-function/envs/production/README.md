# Production Environment

Deploys the sample Scheduled Cloud Function and Cloud Storage bucket workload in the `production` environment using official Cloud Foundation Toolkit (CFT) modules.

## Architecture

This environment invokes two modular components:
1. `modules/bucket`: Wraps `terraform-google-modules/cloud-storage/google` to provision the destination bucket with versioning, uniform bucket-level access, and automated API enablement.
2. `modules/cloud_function`: Wraps `terraform-google-modules/scheduled-function/google` to create a Cloud Scheduler job triggering a Cloud Function via Pub/Sub to write telemetry and assets into the bucket.

## Deployment

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment (automatically defaults to gdg-devfest-demo-prod)
terraform plan

# Apply changes
terraform apply
```

## 🧪 Testing & Verification

Once deployed, verify the end-to-end scheduled serverless pipeline:

### 1. Extract Deployed Resource Names

```bash
BUCKET_NAME=$(terraform output -raw bucket_name)
SCHEDULER_JOB=$(terraform output -raw scheduler_job_name)
TOPIC_NAME=$(terraform output -raw pubsub_topic_name)
PROJECT_ID=$(terraform output -raw project_id)
```

### 2. Trigger the Scheduled Function

Trigger manually without waiting for the cron timer:

```bash
# Option A: Trigger the Cloud Scheduler Job
gcloud scheduler jobs run "$SCHEDULER_JOB" \
  --location=europe-west3 \
  --project="$PROJECT_ID"

# Option B: Publish directly to the Pub/Sub Topic
gcloud pubsub topics publish "$TOPIC_NAME" \
  --message="Prod test from GDG DevFest Berlin 2026" \
  --project="$PROJECT_ID"
```

### 3. Verify Cloud Storage Objects

```bash
# List generated files in the bucket
gcloud storage ls --recursive "gs://$BUCKET_NAME/"

# Inspect the latest JSON telemetry record
LATEST_JSON=$(gcloud storage ls "gs://$BUCKET_NAME/records/production/*.json" | tail -n 1)
gcloud storage cat "$LATEST_JSON"

# Inspect the latest SVG image asset
LATEST_SVG=$(gcloud storage ls "gs://$BUCKET_NAME/images/production/*.svg" | tail -n 1)
gcloud storage cat "$LATEST_SVG"
```

### 4. Check Cloud Function Logs

```bash
gcloud functions logs read fn-datacenter-1-prod \
  --region=europe-west3 \
  --project="$PROJECT_ID" \
  --limit=25
```

## 🧹 Teardown & Cost Protection

To destroy the production workload when finished:

```bash
# Optional: remove generated records from the bucket
gcloud storage rm --recursive "gs://$BUCKET_NAME/**"

# Destroy all Terraform resources
terraform destroy
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Optional override for GCP project ID (defaults to core name in `locals`) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | The adapted GCP project ID (`gdg-devfest-demo-prod`) |
| bucket\_name | The name of the created Cloud Storage bucket |
| bucket\_url | The base URL of the bucket |
| bucket\_service\_account\_email | The email address of the storage manager service account |
| scheduler\_job\_name | The name of the Cloud Scheduler job |
| pubsub\_topic\_name | The Pub/Sub topic triggering the scheduled function |
| cloud\_function\_name | The name of the deployed Cloud Function |
| cloud\_function\_service\_account\_email | The service account email used by the Cloud Function |
| region | The Google Cloud region |
