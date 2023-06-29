# Copyright (c) HashiCorp, Inc.

output "kubernetes_endpoint" {
  description = "The cluster endpoint"
  sensitive   = true
  value       = module.tfc_agent_cluster.endpoint
}

output "client_token" {
  description = "The bearer token for auth"
  sensitive   = true
  value       = base64encode(data.google_client_config.default.access_token)
}

output "ca_certificate" {
  description = "The cluster ca certificate (base64 encoded)"
  sensitive   = true
  value       = module.tfc_agent_cluster.ca_certificate
}

output "service_account" {
  description = "The default service account used for TFC agent nodes."
  value       = module.tfc_agent_cluster.service_account
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.tfc_agent_cluster.name
}

output "network_name" {
  description = "Name of VPC"
  value       = local.network_name
}

output "subnet_name" {
  description = "Name of VPC"
  value       = local.subnet_name
}

output "location" {
  description = "Cluster location"
  value       = module.tfc_agent_cluster.location
}
