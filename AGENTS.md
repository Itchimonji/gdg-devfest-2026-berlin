# AGENTS.md

Welcome to the **GDG DevFest Berlin 2026** speaker session repository: **"Stop Reinventing the Wheel: Building a Secure GCP Foundation with Terraform"**.

This document outlines architectural principles, coding conventions, operational workflows, and security guardrails for AI agents (e.g., Gemini CLI, subagents) and human contributors working within this codebase.

---

## 🎯 Repository Purpose & Scope

- **Primary Goal:** Provide a clear, production-grade, approachable demonstration of how Google Cloud's [**terraform-example-foundation (TEF)**](https://github.com/terraform-google-modules/terraform-example-foundation) structures enterprise infrastructure.
- **Scope:** Demonstrates **Stage 5 (`app-infra`)** workload vending on top of a foundational GCP landing zone.
- **Workload Example:** An automated, scheduled serverless workflow (Cloud Scheduler → Pub/Sub → Cloud Function → Cloud Storage) built strictly using official Google **Cloud Foundation Toolkit (CFT)** modules.

---

## 🛡️ Cloud Foundation Toolkit (CFT) First: Security Architecture

All code generation, module creation, and refactoring in this repository must follow the **Cloud Foundation Toolkit (CFT) First** doctrine. CFT modules embody Google Cloud's official security blueprints and opinionated enterprise defaults.

### 1. Mandatory Module Preference
- **Always Prefer CFT Modules:** Use official `terraform-google-modules/*` and `GoogleCloudPlatform/*` modules rather than handcrafting raw `google_*` primitives for core foundation components:
  - Storage: [`terraform-google-modules/cloud-storage/google`](https://github.com/terraform-google-modules/terraform-google-cloud-storage)
  - Scheduled Serverless: [`terraform-google-modules/scheduled-function/google`](https://github.com/terraform-google-modules/terraform-google-scheduled-function)
  - Projects: `terraform-google-modules/project-factory/google`
  - Networking: `terraform-google-modules/network/google`
- **Module Wrappers:** Wrap CFT modules in `modules/` to enforce organization-wide naming, tagging, region policies, and security guardrails while keeping `envs/` clean and declarative.

### 2. Identity & Access Management (IAM) Security
- **Principle of Least Privilege (PoLP):** Provision dedicated, single-purpose service accounts for each workload (e.g., `sa-${business_unit}-fn-${env_short}`).
- **No Default Service Accounts:** Never bind roles to the default Compute Engine (`{project_number}-compute@developer.gserviceaccount.com`) or App Engine default service accounts.
- **Eliminate Primitive Roles:** Primitive roles (`roles/owner`, `roles/editor`, `roles/viewer`) are strictly prohibited. Always select granular, predefined IAM roles (e.g., `roles/storage.objectUser`, `roles/run.invoker`).
- **Resource-Level Over Project-Level:** Bind permissions directly to the target resource (e.g., `google_storage_bucket_iam_member` on a specific bucket) rather than broad project-level IAM bindings.
- **Non-Authoritative Bindings:** Always prefer `*_iam_member` resources over `*_iam_binding` or `*_iam_policy` to prevent unintentional privilege revocation of other services or automation pipelines.

### 3. Data Protection & Storage Security
- **Uniform Bucket-Level Access (UBLA):** Enforce `uniform_bucket_level_access = true` on every Cloud Storage bucket to disable legacy ACLs and guarantee centralized IAM governance.
- **Public Access Prevention:** Enforce public access prevention (`public_access_prevention = "enforced"` or `"inherited"`) on all data buckets.
- **Object Versioning:** Enable versioning (`versioning = true`) on all state and storage buckets to protect against accidental deletions, data corruption, and ransomware overwrite.
- **Safe Resource Destruction:** Mark `force_destroy = true` only in development/sandbox environments, never in production.

### 4. Serverless & Runtime Hardening
- **Scoped Service Accounts:** Cloud Functions must execute under a dedicated service account carrying only the specific permissions needed for their immediate task (e.g., write-only access to a specific GCS prefix/bucket).
- **No Hardcoded Secrets or Credentials:** Never pass API keys, database passwords, or private keys via plain environment variables. Use Google Secret Manager (`secret_environment_variables`) for sensitive configuration.
- **Resource Limits & Denial-of-Service Defense:** Always configure resource bounding:
  - `available_memory_mb` (e.g., `256M`)
  - `timeout` (e.g., `60s`)
  - `max_instances` (to prevent unbounded scaling costs or resource exhaustion)
- **Ingress & Egress Controls:** Default functions to internal ingress (`ALLOW_INTERNAL_ONLY`) whenever public access is not explicitly required.

### 5. Blast Radius Reduction & State Isolation
- **Environment Isolation:** `development` and `production` environments must NEVER share Terraform state backends, service accounts, or VPC networks.
- **Stage Decoupling:** Workload infrastructure (Stage 5) must consume outputs from foundation stages (0–4) rather than attempting to modify organization-level policies, Shared VPCs, or project billing configurations.

---

## 🏛️ Architectural Standards

### 1. Separation of Environments and Modules
- **`modules/` (`examples/cloud-function/modules/`):**
  - Contains reusable, parameter-driven Terraform modules wrapping official CFT blueprints.
  - Must remain strictly environment-agnostic (no hardcoded project IDs, environments, or regional assumptions).
  - Module wrappers currently implemented:
    - `modules/bucket`: Wraps `terraform-google-modules/cloud-storage/google` (v12.4.x).
    - `modules/cloud_function`: Wraps `terraform-google-modules/scheduled-function/google` (v6.0.x).
- **`envs/` (`examples/cloud-function/envs/`):**
  - Represents concrete deployment environments (`development`, `production`).
  - Contains composition logic (`main.tf`), environment metadata, state backend (`backend.tf`), and output definitions (`outputs.tf`).
  - Cross-environment resource sharing or state leakage is prohibited.

---

## 🏷️ Naming & Identification Conventions (Strict)

When generating or refactoring Terraform code in this repository, agents MUST adhere to these rules:

### 1. GCP Naming Rules & Regex Validation
- Google Cloud service accounts and Cloud Storage buckets **strictly prohibit underscores (`_`)**.
- Service account `account_id` must match `^[a-z]([-a-z0-9]*[a-z0-9])?$` and be between 6 and 30 characters.
- Always sanitize input identifiers using:
  ```hcl
  locals {
    clean_business_unit = replace(var.business_unit, "_", "-")
    clean_project_id    = replace(var.project_id, "_", "-")
  }
  ```
- **Standardized Resource Prefixes:**
  | Resource | Prefix Format | Example |
  | :--- | :--- | :--- |
  | **Storage Bucket** | `bkt-${business_unit}-${env_short}-${suffix}-${rand}` | `bkt-datacenter-1-dev-data-a1b2` |
  | **Service Account** | `sa-${business_unit}-${role}-${env_short}` | `sa-datacenter-1-fn-dev` |
  | **Cloud Function** | `fn-${business_unit}-${env_short}` | `fn-datacenter-1-dev` |
  | **Scheduler Job** | `job-${business_unit}-${env_short}` | `job-datacenter-1-dev` |
  | **Pub/Sub Topic** | `top-${business_unit}-${env_short}` | `top-datacenter-1-dev` |

### 2. Project ID Core Name Adaptation
- The environment `main.tf` defines the core project identifier (e.g. `project_id = "gdg-devfest-demo"`).
- Reusable modules must adapt this core name to the concrete environment project ID:
  ```hcl
  env_project_id = (
    endswith(local.clean_project_id, "-${var.env_short}")
    ? local.clean_project_id
    : "${local.clean_project_id}-${var.env_short}"
  )
  ```
  Resulting in `gdg-devfest-demo-dev` for development and `gdg-devfest-demo-prod` for production.

---

## 🛠️ Developer & Agent Workflows

### 1. Code Formatting & Style
Always ensure all `.tf` files adhere to standard HCL styling:
```bash
terraform fmt -recursive
```

### 2. Validation
Before concluding any modification, validate syntax and provider constraints in both environments:
```bash
# Validate Development
cd examples/cloud-function/envs/development
terraform validate

# Validate Production
cd examples/cloud-function/envs/production
terraform validate
```

### 3. Dry-Run Planning
To test plan generation safely without needing live Google Cloud credentials:
```bash
terraform plan -var="project_id=gdg-devfest-demo-dev" -refresh=false
```

### 4. Post-Deployment Pipeline Verification
When testing live infrastructure deployed to GCP:
```bash
# Extract resource names
BUCKET=$(terraform output -raw bucket_name)
JOB=$(terraform output -raw scheduler_job_name)
PROJECT=$(terraform output -raw project_id)

# 1. Trigger the Cloud Scheduler job
gcloud scheduler jobs run "$JOB" --location=europe-west3 --project="$PROJECT"

# 2. Verify JSON telemetry and SVG image assets written to GCS
gcloud storage ls --recursive "gs://$BUCKET/"

# 3. Inspect Cloud Function logs
gcloud functions logs read fn-datacenter-1-dev --region=europe-west3 --project="$PROJECT" --limit=25
```

### 5. Teardown & Cleanup
Always remind users or execute teardown after test deployments to prevent unexpected costs:
```bash
terraform destroy
```

---

## 🤖 AI Agent Tooling & Submodules

This repository bundles official [Google Cloud Skills](https://github.com/google/skills) under `.gemini/skills/google-skills` for use with the **Gemini CLI**.

### Working with Gemini CLI Skills:
- Use skills in `.gemini/skills/google-skills/skills/cloud/` for authoritative reference on Google Cloud APIs, IAM definitions, and module architectures.
- Relevant skills:
  - `gke-basics` / `gcloud`
  - `bigquery-basics`
  - `agent-platform-*`
- Do not commit changes inside the `.gemini/skills/google-skills` submodule directory unless explicitly instructed to update the submodule pointer.

---

## 🔒 Security & System Integrity Checklist

Agents modifying this repository must enforce:
- [ ] **CFT First:** Official Cloud Foundation Toolkit modules used for all core services.
- [ ] **No Secrets:** Never commit passwords, API keys, GCP service account JSON credentials, or private keys.
- [ ] **Least Privilege:** Granular predefined roles only; no `roles/owner` or `roles/editor`.
- [ ] **UBLA Enabled:** Uniform Bucket-Level Access enforced on all Cloud Storage buckets.
- [ ] **Dedicated SAs:** No default compute or app engine service accounts used.
- [ ] **State Protection:** Never commit `.tfstate` or `.tfstate.backup` files. Ensure `.gitignore` covers all local state and archive outputs.
- [ ] **Idempotency:** Ensure Terraform configurations are idempotent and free of race conditions.
- [ ] **Documentation:** Update matching `README.md` files in `modules/` and `envs/` when inputs or outputs are changed.
