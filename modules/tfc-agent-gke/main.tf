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
  network_name          = var.create_network ? google_compute_network.tfc_agent_network[0].name : var.network_name
  subnet_name           = var.create_network ? google_compute_subnetwork.tfc_agent_subnetwork[0].name : var.subnet_name
  service_account_email = var.create_service_account ? google_service_account.tfc_agent_service_account[0].email : var.service_account_email
  tfc_agent_name        = "${var.tfc_agent_name_prefix}-${random_string.suffix.result}"
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
  IAM Bindings GKE
 *****************************************/

resource "google_service_account" "tfc_agent_service_account" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = "tfc-agent-gke"
  display_name = "Terraform Cloud agent GKE Service Account"
}

/*****************************************
  TFC agent GKE
 *****************************************/

module "tfc_agent_cluster" {
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster/"
  version                  = "~> 30.0"
  project_id               = var.project_id
  region                   = var.region
  zones                    = var.zones
  network                  = local.network_name
  name                     = local.tfc_agent_name
  subnetwork               = local.subnet_name
  service_account          = local.service_account_email
  network_project_id       = var.network_project_id != "" ? var.network_project_id : var.project_id
  ip_range_pods            = var.ip_range_pods_name
  ip_range_services        = var.ip_range_services_name
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool = true
  regional                 = false
  gce_pd_csi_driver        = true
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
  K8S resources for configuring TFC agent
 *****************************************/

data "google_client_config" "default" {
}

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

# Deploy the agent
resource "kubernetes_deployment" "tfc_agent_deployment" {
  metadata {
    name = "${local.tfc_agent_name}-deployment"
  }

  spec {
    selector {
      match_labels = {
        app = local.tfc_agent_name
      }
    }

    replicas = var.tfc_agent_min_replicas

    template {
      metadata {
        labels = {
          app = local.tfc_agent_name
        }
      }

      spec {
        container {
          name  = local.tfc_agent_name
          image = var.tfc_agent_image

          env {
            name = "TFC_ADDRESS"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_address"
              }
            }
          }

          env {
            name = "TFC_AGENT_TOKEN"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_token"
              }
            }
          }

          env {
            name = "TFC_AGENT_NAME"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_name"
              }
            }
          }

          env {
            name = "TFC_AGENT_SINGLE"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_single"
              }
            }
          }

          env {
            name = "TFC_AGENT_AUTO_UPDATE"
            value_from {
              secret_key_ref {
                name = var.tfc_agent_k8s_secrets
                key  = "tfc_agent_auto_update"
              }
            }
          }

          # https://developer.hashicorp.com/terraform/cloud-docs/agents/requirements
          resources {
            requests = {
              memory = var.tfc_agent_memory_request
              cpu    = var.tfc_agent_cpu_request
            }
          }
        }
      }
    }
  }
}

# Deploy a horizontal pod autoscaler for the agent
resource "kubernetes_horizontal_pod_autoscaler_v2" "tfc_agent_hpa" {
  metadata {
    name = "${local.tfc_agent_name}-deployment-hpa"
  }

  spec {
    scale_target_ref {
      kind = "Deployment"
      name = "${local.tfc_agent_name}-deployment"
    }

    min_replicas = var.tfc_agent_min_replicas
    max_replicas = var.tfc_agent_max_replicas

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}
