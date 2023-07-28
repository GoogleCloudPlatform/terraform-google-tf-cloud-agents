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
  description = "The Google Cloud Platform project ID to use"
}

variable "service_list" {
  description = "Google Cloud APIs required for the project"
  type        = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com"
  ]
}

variable "pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
}

variable "pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
  default     = null
}

variable "pool_description" {
  type        = string
  description = "Workload Identity Pool description"
  default     = "Workload Identity Pool managed by Terraform"
}

variable "provider_id" {
  type        = string
  description = "Workload Identity Pool Provider ID"
}

variable "provider_display_name" {
  type        = string
  description = "Workload Identity Pool Provider display name"
  default     = null
}

variable "provider_description" {
  type        = string
  description = "Workload Identity Pool Provider description"
  default     = "Workload Identity Pool Provider managed by Terraform"
}


# For more info please see
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
variable "attribute_condition" {
  type        = string
  description = "Workload Identity Pool Provider attribute condition expression"
  default     = ""
}

# For more info please see
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
variable "attribute_mapping" {
  type        = map(any)
  description = "Workload Identity Pool Provider attribute mapping"
  default = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_project_id"        = "assertion.terraform_project_id",
    "attribute.terraform_project_name"      = "assertion.terraform_project_name",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }
}

variable "allowed_audiences" {
  type        = list(string)
  description = "Workload Identity Pool Provider allowed audiences"
  default     = []
}

variable "issuer_uri" {
  type        = string
  description = <<-EOF
    Workload Identity Pool Issuer URL for Terraform Cloud/Enterprise.
    The default audience format used by TFC is of the form
    //iam.googleapis.com/projects/{project_id}/locations/global/workloadIdentityPools/{pool_id}/providers/{provider_id}
    which matches with the default accepted audience format on GCP
  EOF
  default     = "https://app.terraform.io"
}

variable "tfc_organization_name" {
  type        = string
  description = "The Terraform Cloud organization to use"
}

variable "tfc_project_name" {
  type        = string
  default     = "Default Project"
  description = "The Terraform Cloud project to use"
}

variable "tfc_workspace_name" {
  type        = string
  default     = "gcp-oidc-workspace"
  description = "The Terraform Cloud workspace to authorize via OIDC"
}

variable "sa_mapping" {
  type = map(object({
    sa_name   = string
    sa_email  = string
    attribute = string
  }))
  description = <<-EOF
    Service Account resource names and corresponding WIF provider attributes.
    If attribute is set to `*` all identities in the pool are granted access to SAs
  EOF
  default     = {}
}
