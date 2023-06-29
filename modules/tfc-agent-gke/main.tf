# Copyright (c) HashiCorp, Inc.

locals {
  network_name    = var.create_network ? google_compute_network.tfc_agent_network[0].name : var.network_name
  subnet_name     = var.create_network ? google_compute_subnetwork.tfc_agent_subnetwork[0].name : var.subnet_name
  service_account = var.service_account == "" ? "create" : var.service_account
  tfc_agent_name  = "${var.tfc_agent_name_prefix}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

/*****************************************
  Optional Network
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
  secondary_ip_range = [
    {
      range_name    = var.ip_range_pods_name
      ip_cidr_range = var.ip_range_pods_cidr
    },
    { range_name    = var.ip_range_services_name
      ip_cidr_range = var.ip_range_services_cider
    }
  ]
}

/*****************************************
  TFC Agent GKE
 *****************************************/

module "tfc_agent_cluster" {
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster/"
  version                  = "~> 24.0"
  project_id               = var.project_id
  name                     = local.tfc_agent_name
  regional                 = false
  region                   = var.region
  zones                    = var.zones
  network                  = local.network_name
  network_project_id       = var.subnetwork_project != "" ? var.subnetwork_project : var.project_id
  subnetwork               = local.subnet_name
  ip_range_pods            = var.ip_range_pods_name
  ip_range_services        = var.ip_range_services_name
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool = true
  service_account          = local.service_account
  node_pools = [
    {
      name         = "tfc-agent-pool"
      min_count    = var.min_node_count
      max_count    = var.max_node_count
      auto_upgrade = true
      machine_type = var.machine_type
    }
  ]
}

/*****************************************
  IAM Bindings GKE SVC
 *****************************************/

# Allow GKE to pull images from GCR
resource "google_project_iam_member" "gke" {
  count   = var.service_account == "" ? 1 : 0
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${module.tfc_agent_cluster.service_account}"
}

data "google_client_config" "default" {
}

/*****************************************
  K8S secrets for configuring TFC agent
 *****************************************/

resource "kubernetes_secret" "tfc_agent_secrets" {
  metadata {
    name = var.tfc_agent_k8s_secrets
  }
  data = {
    tfc_agent_address     = var.tfc_agent_address
    tfc_agent_token       = var.tfc_agent_token
    tfc_agent_single      = var.tfc_agent_single
    tfc_agent_auto_update = var.tfc_agent_auto_update
    tfc_agent_name        = local.tfc_agent_name
  }
}
