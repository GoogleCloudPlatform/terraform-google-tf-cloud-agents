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

variable "project_id" {
  type        = string
  description = "The Google Cloud Platform project ID to deploy Terraform Cloud agent"
}

variable "region" {
  type        = string
  description = "The GCP region to use when deploying resources"
  default     = "us-central1"
}

variable "create_network" {
  type        = bool
  description = "When set to true, VPC, router and NAT will be auto created"
  default     = false
}

variable "network_name" {
  type        = string
  description = "Name for the VPC network"
}

variable "subnetwork_project" {
  type        = string
  description = <<-EOF
    The project ID of the shared VPCs host (for shared vpc support).
    If not provided, the project_id is used
  EOF
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
  description = "The Terraform Cloud agent image"
  default     = "hashicorp/tfc-agent:latest"
}

variable "target_size" {
  type        = number
  description = "The number of Terraform Cloud agent instances"
  default     = 2
}

variable "create_service_account" {
  description = "Set to true to create a new service account, false to use an existing one"
  type        = bool
  default     = true
}

variable "service_account_email" {
  type        = string
  description = "Service account email address to use with the MIG template, required if create_service_account is set to false"
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
  type        = number
  description = <<-EOF
    The number of seconds that the autoscaler should wait before it
    starts collecting information from a new instance.
  EOF
  default     = 60
}

variable "startup_script" {
  type        = string
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "tfc_agent_address" {
  type        = string
  description = "The HTTP or HTTPS address of the Terraform Cloud/Enterprise API"
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
  description = "Terraform Cloud agent token. (Organization Settings >> Agents)"
  sensitive   = true
}
