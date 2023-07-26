# Copyright (c) HashiCorp, Inc.

provider "kubernetes" {
  host                   = "https://${module.tfc_agent_gke.kubernetes_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.tfc_agent_gke.ca_certificate)
}
