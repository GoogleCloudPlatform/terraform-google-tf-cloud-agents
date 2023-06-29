# Copyright (c) HashiCorp, Inc.

variable "project_id" {
  type        = string
  description = "The project id to deploy Terraform Agent"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy instances into"
  default     = "us-central1"
}

variable "network_name" {
  type        = string
  description = "Name for the VPC network"
  default     = "tfc-agent-network"
}

variable "create_network" {
  type        = bool
  description = "When set to true, VPC,router and NAT will be auto created"
  default     = true
}

variable "subnetwork_project" {
  type        = string
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the project_id is used."
  default     = ""
}

variable "subnet_ip" {
  type        = string
  description = "IP range for the subnet"
  default     = "10.10.10.0/24"
}

variable "subnet_name" {
  type        = string
  description = "Name for the subnet"
  default     = "tfc-agent-subnet"
}

variable "restart_policy" {
  type        = string
  description = "The desired Docker restart policy for the agent image"
  default     = "Always"
}

variable "image" {
  type        = string
  description = "The Terraform Agent image"
  default     = "hashicorp/tfc-agent:latest"
}

variable "target_size" {
  type        = number
  description = "The number of Terraform Cloud Agent instances"
  default     = 2
}

variable "service_account" {
  description = "Service account email address"
  type        = string
  default     = ""
}
variable "additional_metadata" {
  type        = map(any)
  description = "Additional metadata to attach to the instance"
  default     = {}
}

variable "dind" {
  type        = bool
  description = "Flag to determine whether to expose dockersock "
  default     = false
}

variable "cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  type        = number
  default     = 60
}

variable "startup_script" {
  type        = string
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "tfc_agent_address" {
  type        = string
  description = "The HTTP or HTTPS address of the Terraform Cloud/Enterprise API."
  default     = "https://app.terraform.io"
}

variable "tfc_agent_single" {
  type        = bool
  default     = false
  description = <<-EOF
    Enable single mode. This causes the agent to handle at most one job and
    immediately exit thereafter. Useful for running agents as ephemeral
    containers, VMs, or other isolated contexts with a higher-level scheduler
    or process supervisor.
  EOF
}

variable "tfc_agent_auto_update" {
  type        = string
  description = "Controls automatic core updates behavior. Acceptable values include disabled, patch, and minor"
  default     = "minor"
}

variable "tfc_agent_name_prefix" {
  type        = string
  description = "This name may be used in the Terraform Cloud user interface to help easily identify the agent"
  default     = "tfc-agent-container-vm"
}

variable "tfc_agent_token" {
  type        = string
  description = "Terraform Cloud agent token. (mark as sensitive) (TFC Organization Settings >> Agents)"
}
