# Copyright (c) HashiCorp, Inc.

output "mig_instance_group" {
  description = "The instance group url of the created MIG"
  value       = module.mig.instance_group
}

output "mig_name" {
  description = "The name of the MIG"
  value       = local.instance_name
}

output "mig_instance_template" {
  description = "The name of the MIG Instance Template"
  value       = module.mig_template.name
}

output "network_name" {
  description = "Name of VPC"
  value       = local.network_name
}

output "subnet_name" {
  description = "Name of VPC"
  value       = local.subnet_name
}

output "service_account" {
  description = "Service account email for GCE"
  value       = local.service_account
}
