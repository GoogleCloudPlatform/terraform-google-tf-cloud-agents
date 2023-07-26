# Copyright (c) HashiCorp, Inc.

output "mig_instance_group" {
  description = "The instance group url of the created MIG"
  value       = module.tfc_agent_mig.mig_instance_group
}

output "mig_name" {
  description = "The name of the MIG"
  value       = module.tfc_agent_mig.mig_name
}

output "service_account" {
  description = "Service account email used with the MIG template"
  value       = module.tfc_agent_mig.service_account
}

output "mig_instance_template" {
  description = "The name of the MIG Instance Template"
  value       = module.tfc_agent_mig.mig_instance_template
}
