/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Get the Terraform Cloud organization
data "tfe_organization" "tfc_org" {
  name = var.tfc_org_name
}

# Get the Terraform Cloud organization project, make sure it exists
data "tfe_project" "tfc_project" {
  name         = var.tfc_project_name
  organization = data.tfe_organization.tfc_org.name
}

locals {
  tfc_workspace = "${var.tfc_workspace_name}-${random_string.suffix.result}"
}

# Random ID for the workload_identity_pool_id
# will avoid errors due to GCP's 30-day hold on deleted pools
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Create a new workspace which uses the agent to run Terraform
resource "tfe_workspace" "tfc_workspace" {
  name         = local.tfc_workspace
  organization = data.tfe_organization.tfc_org.name
  project_id   = data.tfe_project.tfc_project.id
}

# Create a new Service Account in Google Cloud
resource "google_service_account" "sa" {
  project    = var.project_id
  account_id = "terraform-storage-sa"
}

# Give the service account necessary permissions,
# for ex. storage access - see role_list variable
resource "google_project_iam_member" "project" {
  project  = var.project_id
  for_each = toset(var.role_list)
  role     = each.value
  member   = "serviceAccount:${google_service_account.sa.email}"
}

# The following variables must be set to allow runs
# to authenticate to GCP.
resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.tfc_workspace.id
  key          = "TFC_GCP_PROVIDER_AUTH"
  value        = "true"
  category     = "env"

  description = "Enable the Workload Identity integration for GCP."
}

# TFC_GCP_WORKLOAD_PROVIDER_NAME variable contains the project number,
# pool ID, and provider ID
resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.tfc_workspace.id
  key          = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value        = module.oidc.provider_name
  category     = "env"
  description  = "The workload provider name to authenticate against."
}

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.tfc_workspace.id
  key          = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value        = google_service_account.sa.email
  category     = "env"
  description  = "The GCP service account TFC agents will use to authenticate."
}

# Use the OIDC module to provision the Workload identitly pool
module "oidc" {
  source  = "GoogleCloudPlatform/tf-cloud-agents/google//modules/tfc-oidc"
  version = "~> 0.1"

  project_id  = var.project_id
  pool_id     = "pool-${random_string.suffix.result}"
  provider_id = "terraform-provider-${random_string.suffix.result}"
  sa_mapping = {
    (google_service_account.sa.account_id) = {
      sa_name   = google_service_account.sa.name
      sa_email  = google_service_account.sa.email
      attribute = "*"
    }
  }
  tfc_organization_name = data.tfe_organization.tfc_org.name
  tfc_project_name      = data.tfe_project.tfc_project.name
  tfc_workspace_name    = tfe_workspace.tfc_workspace.name
}
