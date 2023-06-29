# Copyright (c) HashiCorp, Inc.

output "kubernetes_endpoint" {
  description = "The cluster endpoint"
  sensitive   = true
  value       = module.tfc_agent_gke.kubernetes_endpoint
}

output "client_token" {
  description = "The bearer token for auth"
  sensitive   = true
  value       = module.tfc_agent_gke.client_token
}

output "ca_certificate" {
  description = "The cluster ca certificate (base64 encoded)"
  sensitive   = true
  value       = module.tfc_agent_gke.ca_certificate
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.tfc_agent_gke.service_account
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.tfc_agent_gke.cluster_name
}

output "network_name" {
  description = "Name of VPC"
  value       = module.tfc_agent_gke.network_name
}

output "subnet_name" {
  description = "Name of VPC"
  value       = module.tfc_agent_gke.subnet_name
}

output "location" {
  description = "Cluster location"
  value       = module.tfc_agent_gke.location
}
