/**
 * Copyright 2019 Google LLC
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

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  name                = "ci-tf-cloud-agents"
  random_project_id   = "true"
  org_id              = var.org_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = true

  activate_apis = [
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

data "tfe_organization" "tfc_org" {
  name = var.tfc_org_name
}

resource "google_artifact_registry_repository" "hashicorp" {
  project       = module.project.project_id
  location      = "us-central1"
  repository_id = "hashicorp"
  description   = "HashiCorp Docker repository"
  format        = "DOCKER"
}

resource "local_file" "env_file" {
  filename = "${path.module}/outputs.env"
  content  = <<EOT
_SETUP_PROJECT_ID=${module.project.project_id}
EOT
}
