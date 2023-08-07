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

locals {
  network_name    = var.create_network ? google_compute_network.tfc_agent_network[0].self_link : var.network_name
  service_account = var.service_account == "" ? google_service_account.tfc_agent_service_account[0].email : var.service_account
  startup_script  = var.startup_script == "" ? file("${path.module}/scripts/startup.sh") : var.startup_script
  instance_name   = "${var.tfc_agent_name_prefix}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

/*****************************************
  Optional Terraform agent Networking
 *****************************************/

resource "google_compute_network" "tfc_agent_network" {
  count                   = var.create_network ? 1 : 0
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "tfc_agent_subnetwork" {
  count         = var.create_network ? 1 : 0
  project       = var.project_id
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip
  region        = var.region
  network       = local.network_name
}

resource "google_compute_router" "tfc_agent_router" {
  count   = var.create_network ? 1 : 0
  name    = "${var.network_name}-router"
  network = google_compute_network.tfc_agent_network[0].self_link
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "tfc_agent_nat" {
  count                              = var.create_network ? 1 : 0
  project                            = var.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.tfc_agent_router[0].name
  region                             = google_compute_router.tfc_agent_router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

/*****************************************
  IAM Bindings GCE SVC
 *****************************************/

resource "google_service_account" "tfc_agent_service_account" {
  count        = var.service_account == "" ? 1 : 0
  project      = var.project_id
  account_id   = "tfc-agent-mig-vm-sa"
  display_name = "Terraform Cloud agent GCE Service Account"
}

/*****************************************
  Terraform agent Secrets
 *****************************************/

resource "google_secret_manager_secret" "tfc_agent_secret" {
  provider  = google-beta
  project   = var.project_id
  secret_id = "tfc-agent"

  labels = {
    label = "tfc-agent"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "tfc_agent_secret_version" {
  provider = google-beta
  secret   = google_secret_manager_secret.tfc_agent_secret.id
  secret_data = jsonencode({
    "TFC_AGENT_NAME"        = local.instance_name
    "TFC_ADDRESS"           = var.tfc_agent_address
    "TFC_AGENT_TOKEN"       = var.tfc_agent_token
    "TFC_AGENT_SINGLE"      = var.tfc_agent_single
    "TFC_AGENT_AUTO_UPDATE" = var.tfc_agent_auto_update
    "AGENT_VERSION"         = var.tfc_agent_version
    "LABELS"                = join(",", var.tfc_agent_labels)
  })
}

resource "google_secret_manager_secret_iam_member" "tfc_agent_secret_member" {
  provider  = google-beta
  project   = var.project_id
  secret_id = google_secret_manager_secret.tfc_agent_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.service_account}"
}

/*****************************************
  Terraform agent GCE Instance Template
 *****************************************/

module "mig_template" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "~> 7.0"
  project_id         = var.project_id
  machine_type       = var.machine_type
  network            = local.network_name
  subnetwork         = var.subnet_name
  region             = var.region
  subnetwork_project = var.network_project != "" ? var.network_project : var.project_id
  service_account = {
    email = local.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  disk_size_gb         = 100
  disk_type            = "pd-ssd"
  auto_delete          = true
  source_image         = var.source_image
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project
  name_prefix          = var.tfc_agent_name_prefix
  startup_script       = local.startup_script
  metadata = merge({
    "secret-id" = google_secret_manager_secret_version.tfc_agent_secret_version.name
  }, var.custom_metadata)
  tags = [
    local.instance_name
  ]
}

/*****************************************
  Terraform agent MIG
 *****************************************/

module "mig" {
  source             = "terraform-google-modules/vm/google//modules/mig"
  version            = "~> 7.0"
  project_id         = var.project_id
  subnetwork_project = var.project_id
  region             = var.region
  hostname           = local.instance_name
  instance_template  = module.mig_template.self_link

  /* autoscaler */
  autoscaling_enabled = true
  min_replicas        = var.min_replicas
  max_replicas        = var.max_replicas
  cooldown_period     = var.cooldown_period
}
