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
  description = "The project id to create WIF pool and example SA"
}

variable "tfc_org_name" {
  type        = string
  description = "Terraform Cloud org name where the WIF pool will be attached"
}

variable "tfc_project_name" {
  type        = string
  description = "Terraform Cloud project name where the WIF pool will be attached"
  default     = "GCP OIDC"
}

variable "tfc_workspace_name" {
  type        = string
  description = "Terraform Cloud workspace name where the WIF pool will be attached"
  default     = "gcp-oidc"
}

variable "role_list" {
  description = "Google Cloud roles required for the Service Account"
  type        = list(string)
  default = [
    "roles/storage.admin"
  ]
}
