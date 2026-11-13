"""Scheduled Cloud Function triggered by Pub/Sub that stores data and open source image assets into Google Cloud Storage."""

import base64
import json
import os
import uuid
from datetime import datetime, timezone
from google.cloud import storage

# Initialize Google Cloud Storage client
storage_client = storage.Client()
DESTINATION_BUCKET = os.environ.get("BUCKET_NAME", "")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "dev")


def store_data(event, context=None):
    """Entry point for Cloud Pub/Sub triggered Cloud Function.

    Triggered on schedule by Cloud Scheduler via Pub/Sub topic.
    """
    if not DESTINATION_BUCKET:
        print("Error: BUCKET_NAME environment variable is not configured.")
        return

    # Extract Pub/Sub message data if present
    pubsub_message = ""
    if isinstance(event, dict) and "data" in event:
        try:
            pubsub_message = base64.b64decode(event["data"]).decode("utf-8")
        except Exception:
            pubsub_message = str(event["data"])

    try:
        bucket = storage_client.bucket(DESTINATION_BUCKET)
        record_id = str(uuid.uuid4())[:8]
        timestamp = datetime.now(timezone.utc).isoformat()

        record_data = {
            "record_id": record_id,
            "timestamp": timestamp,
            "environment": ENVIRONMENT,
            "event": "gdg-devfest-2026-berlin",
            "trigger": "cloud-scheduler",
            "message": pubsub_message or "Scheduled execution from Cloud Scheduler via Pub/Sub",
            "status": "success",
            "payload": {
                "service": "scheduled-function",
                "framework": "terraform-google-scheduled-function",
            },
        }

        # 1. Store the JSON record in the GCS bucket
        json_blob_name = f"records/{ENVIRONMENT}/{timestamp}-{record_id}.json"
        json_blob = bucket.blob(json_blob_name)
        json_blob.upload_from_string(
            data=json.dumps(record_data, indent=2),
            content_type="application/json",
        )
        print(f"Successfully stored record: gs://{DESTINATION_BUCKET}/{json_blob_name}")

        # 2. Store a lightweight open-source SVG image asset in the GCS bucket
        svg_content = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 120" width="400" height="120">
  <rect width="100%" height="100%" rx="15" fill="#34A853"/>
  <text x="20" y="45" font-family="Roboto, sans-serif" font-size="20" font-weight="bold" fill="#ffffff">GDG DevFest Berlin 2026</text>
  <text x="20" y="75" font-family="Roboto, sans-serif" font-size="14" fill="#e8f0fe">CFT Scheduled Cloud Function</text>
  <text x="20" y="100" font-family="monospace" font-size="11" fill="#cbf0f8">ID: {record_id} | Env: {ENVIRONMENT}</text>
</svg>"""

        image_blob_name = f"images/{ENVIRONMENT}/{timestamp}-{record_id}.svg"
        image_blob = bucket.blob(image_blob_name)
        image_blob.upload_from_string(
            data=svg_content,
            content_type="image/svg+xml",
        )
        print(f"Successfully stored image: gs://{DESTINATION_BUCKET}/{image_blob_name}")

    except Exception as exc:
        print(f"Error during execution: {exc}")
        raise
