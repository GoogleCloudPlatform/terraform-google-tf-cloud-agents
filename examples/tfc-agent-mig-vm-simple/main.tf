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
  tfc_workspace  = "${var.tfc_workspace_name}-${random_string.suffix.result}"
  tfc_agent_pool = "${var.tfc_agent_pool_name}-${random_string.suffix.result}"
  network_name   = "tfc-vm-simple-${random_string.suffix.result}"
}

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

resource "tfe_workspace_settings" "tfc_workspace_settings" {
  workspace_id   = tfe_workspace.tfc_workspace.id
  agent_pool_id  = tfe_agent_pool.tfc_agent_pool.id
  execution_mode = "agent"
}

# Create a new agent pool in organization
resource "tfe_agent_pool" "tfc_agent_pool" {
  name         = local.tfc_agent_pool
  organization = data.tfe_organization.tfc_org.name
}

# Create a new token for the agent pool
resource "tfe_agent_token" "tfc_agent_token" {
  agent_pool_id = tfe_agent_pool.tfc_agent_pool.id
  description   = var.tfc_agent_pool_token_description
}

# Create a new service account
resource "google_service_account" "tfc_agent_service_account" {
  project      = var.project_id
  account_id   = "tfc-agent-mig-vm-sa"
  display_name = "Terraform Cloud agent VM simple Service Account"
}

# Create the infrastructure for the agent to run
module "tfc_agent_mig" {
  source  = "GoogleCloudPlatform/tf-cloud-agents/google//modules/tfc-agent-mig-vm"
  version = "~> 0.1"

  project_id             = var.project_id
  create_network         = true
  network_name           = local.network_name
  subnet_name            = local.network_name
  tfc_agent_token        = tfe_agent_token.tfc_agent_token.token
  create_service_account = false
  service_account_email  = google_service_account.tfc_agent_service_account.email
}
