# Copyright (c) HashiCorp, Inc.

variable "project_id" {
  type        = string
  description = "The Google Cloud Platform project ID to deploy Terraform Cloud agent MIG"
}

variable "tfc_org_name" {
  type        = string
  description = "Terraform Cloud org name where the agent pool will be created"
}

variable "tfc_project_name" {
  type        = string
  description = "Terraform Cloud project name to be created"
  default     = "GCP agents custom VM"
}

variable "tfc_workspace_name" {
  type        = string
  description = "Terraform Cloud workspace name to be created"
  default     = "tfc-agent-mig-vm-packer"
}

variable "tfc_agent_pool_name" {
  type        = string
  description = "Terraform Cloud agent pool name to be created"
  default     = "tfc-agent-mig-vm-packer-pool"
}

variable "tfc_agent_pool_token_description" {
  type        = string
  description = "Terraform Cloud agent pool token description"
  default     = "tfc-agent-mig-vm-packer-pool-token"
}

variable "source_image_project" {
  type        = string
  description = "Project where the source image comes from"
  default     = null
}

variable "source_image" {
  type        = string
  description = "Source disk image"
}
