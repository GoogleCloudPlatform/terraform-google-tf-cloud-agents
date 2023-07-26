# Copyright (c) HashiCorp, Inc.

data "google_client_config" "default" {
}

# Get the Terraform Cloud organization
data "tfe_organization" "tfc_org" {
  name = var.tfc_org_name
}

# Create a new project in Terraform Cloud
resource "tfe_project" "tfc_project" {
  organization = data.tfe_organization.tfc_org.name
  name         = var.tfc_project_name
}

# Create a new workspace which uses the agent to run Terraform
resource "tfe_workspace" "tfc_workspace" {
  name           = var.tfc_workspace_name
  organization   = data.tfe_organization.tfc_org.name
  project_id     = tfe_project.tfc_project.id
  agent_pool_id  = tfe_agent_pool.tfc_agent_pool.id
  execution_mode = "agent"
}

# Create a new agent pool in organization
resource "tfe_agent_pool" "tfc_agent_pool" {
  name         = var.tfc_agent_pool_name
  organization = data.tfe_organization.tfc_org.name
}

# Create a new token for the agent pool
resource "tfe_agent_token" "tfc_agent_token" {
  agent_pool_id = tfe_agent_pool.tfc_agent_pool.id
  description   = var.tfc_agent_pool_token_description
}

# Allow GKE to pull images from Google Artifact Registry
resource "google_project_iam_member" "gar_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${module.tfc_agent_gke.service_account}"
}

resource "google_project_iam_member" "gar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${module.tfc_agent_gke.service_account}"
}

# Create the infrastructure for the agent to run
module "tfc_agent_gke" {
  source          = "../../modules/tfc-agent-gke"
  create_network  = true
  project_id      = var.project_id
  tfc_agent_image = var.tfc_agent_image
  tfc_agent_token = tfe_agent_token.tfc_agent_token.token
}
