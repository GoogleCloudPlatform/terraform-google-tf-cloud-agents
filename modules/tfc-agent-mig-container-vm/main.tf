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
  dind_volume_mounts = var.dind ? [{
    mountPath = "/var/run/docker.sock"
    name      = "dockersock"
    readOnly  = false
  }] : []
  dind_volumes = var.dind ? [
    {
      name = "dockersock"

      hostPath = {
        path = "/var/run/docker.sock"
      }
  }] : []
  network_name          = var.create_network ? google_compute_network.tfc_agent_network[0].self_link : var.network_name
  subnet_name           = var.create_network ? google_compute_subnetwork.tfc_agent_subnetwork[0].self_link : var.subnet_name
  service_account_email = var.create_service_account ? google_service_account.tfc_agent_service_account[0].email : var.service_account_email
  instance_name         = "${var.tfc_agent_name_prefix}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

/*****************************************
  Optional TFC agent Networking
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
  network       = google_compute_network.tfc_agent_network[0].name
}

resource "google_compute_router" "default" {
  count   = var.create_network ? 1 : 0
  name    = "${var.network_name}-router"
  network = google_compute_network.tfc_agent_network[0].self_link
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  count                              = var.create_network ? 1 : 0
  project                            = var.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.default[0].name
  region                             = google_compute_router.default[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

/*****************************************
  IAM Bindings GCE SVC
 *****************************************/

resource "google_service_account" "tfc_agent_service_account" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = "tfc-agent-mig-container-vm-sa"
  display_name = "Terrform agent GCE Service Account"
}

# allow GCE to pull images from GCR
resource "google_project_iam_member" "gce" {
  count   = var.create_service_account ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${local.service_account_email}"
}

/*****************************************
  TFC agent GCE Instance Template
 *****************************************/

module "gce_container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.0"
  container = {
    image = var.image
    env = [
      {
        name  = "TFC_AGENT_NAME"
        value = local.instance_name
      },
      {
        name  = "TFC_AGENT_TOKEN"
        value = var.tfc_agent_token
      },
      {
        name  = "TFC_ADDRESS"
        value = var.tfc_agent_address
      },
      {
        name  = "TFC_AGENT_AUTO_UPDATE"
        value = var.tfc_agent_auto_update
      },
      {
        name  = "TFC_AGENT_SINGLE"
        value = var.tfc_agent_single
      }
    ]

    # Declare volumes to be mounted
    # This is similar to how Docker volumes are mounted
    volumeMounts = concat([
      {
        mountPath = "/cache"
        name      = "tempfs-0"
        readOnly  = false
      }
    ], local.dind_volume_mounts)
  }

  # Declare the volumes
  volumes = concat([
    {
      name = "tempfs-0"

      emptyDir = {
        medium = "Memory"
      }
    }
  ], local.dind_volumes)

  restart_policy = var.restart_policy
}

module "mig_template" {
  source             = "terraform-google-modules/vm/google//modules/instance_template"
  version            = "~> 7.0"
  region             = var.region
  project_id         = var.project_id
  network            = local.network_name == "" ? null : local.network_name 
  subnetwork         = local.subnet_name
  subnetwork_project = var.subnetwork_project != "" ? var.subnetwork_project : var.project_id
  service_account = {
    email = local.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  disk_size_gb         = 100
  disk_type            = "pd-ssd"
  auto_delete          = true
  source_image_family  = "cos-stable"
  source_image_project = "cos-cloud"
  startup_script       = var.startup_script
  name_prefix          = var.tfc_agent_name_prefix
  source_image         = reverse(split("/", module.gce_container.source_image))[0]
  metadata = merge(var.additional_metadata, {
    google-logging-enabled      = "true"
    "gce-container-declaration" = module.gce_container.metadata_value
  })
  tags = [
    local.instance_name
  ]
  labels = {
    container-vm = module.gce_container.vm_container_label
  }
}

/*****************************************
  TFC agent MIG
 *****************************************/

module "mig" {
  source             = "terraform-google-modules/vm/google//modules/mig"
  version            = "~> 7.0"
  region             = var.region
  project_id         = var.project_id
  subnetwork_project = var.project_id
  target_size        = var.target_size
  hostname           = local.instance_name
  instance_template  = module.mig_template.self_link

  /* autoscaler */
  autoscaling_enabled = true
  cooldown_period     = var.cooldown_period
}
