# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Terraform Cloud agent Packer build for a Google Cloud VM based on Ubuntu 22.04

packer {
  required_version = ">= 1.7.0"
  required_plugins {
    googlecompute = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "disk_size" {
  type        = number
  description = "Size of the disk to create, in GB"
  default     = 10
}

variable "disk_type" {
  type        = string
  description = "Type of disk for the build VM"
  default     = "pd-balanced"
}

variable "image_family" {
  type        = string
  description = "Image family for the new image"
  default     = "tfc-agent-image"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the build VM"
  default     = "e2-small"
}

variable "project_id" {
  type        = string
  description = "The Google Cloud project where the image will be built and stored"
  default     = "${env("PACKER_PROJECT_ID")}"
}

variable "region" {
  type        = string
  description = "The Google Cloud region where the image will be built"
  default     = "us-central1"
}

variable "source_image_family" {
  type        = string
  description = "Source image family for the new custom image"
  default     = "ubuntu-2204-lts"
}

variable "source_image_project_id" {
  type        = string
  description = "Project containing the source image"
  default     = "ubuntu-os-cloud"
}

variable "ssh_username" {
  type        = string
  description = "User name for SSH provisioner connections"
  default     = "ubuntu"
}

variable "tfc_agent_image" {
  type        = string
  description = "The name of the Terraform Cloud image to use"
  default     = "tfc-agent-image"
}

variable "tfc_agent_version" {
  type        = string
  description = "Version of the Terraform Cloud agent to install in the image"
  default     = "${env("TFC_AGENT_VERSION")}"
}

variable "zone" {
  type        = string
  description = "The zone where the image will be built"
  default     = "us-central1-a"
}

source "googlecompute" "agent" {
  project_id              = var.project_id
  source_image_family     = var.source_image_family
  source_image_project_id = [var.source_image_project_id]
  zone                    = var.zone
  machine_type            = var.machine_type
  disk_size               = var.disk_size
  disk_type               = var.disk_type
  ssh_username            = var.ssh_username
  image_name              = var.tfc_agent_image
  image_family            = var.image_family
  use_os_login            = true

  disable_default_service_account = false
}

build {
  sources = ["source.googlecompute.agent"]

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get dist-upgrade -q -y",
      "apt-get update",
      "apt-get install -q -y apt-transport-https ca-certificates curl unzip tar jq build-essential gnupg2 software-properties-common",
      "install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "chmod a+r /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update",
      "apt-get install -y docker-ce",
      "usermod -aG docker ubuntu"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "curl -s -O https://releases.hashicorp.com/tfc-agent/${var.tfc_agent_version}/tfc-agent_${var.tfc_agent_version}_linux_amd64.zip",
      "curl -s -O https://releases.hashicorp.com/tfc-agent/${var.tfc_agent_version}/tfc-agent_${var.tfc_agent_version}_SHA256SUMS",
      "curl -s -O https://releases.hashicorp.com/tfc-agent/${var.tfc_agent_version}/tfc-agent_${var.tfc_agent_version}_SHA256SUMS.sig",
      "curl -s -o hashicorp.asc https://www.hashicorp.com/.well-known/pgp-key.txt",
      "gpg --import hashicorp.asc",
      "gpg --verify tfc-agent_${var.tfc_agent_version}_SHA256SUMS.sig tfc-agent_${var.tfc_agent_version}_SHA256SUMS",
      "shasum -a 256 -c tfc-agent_${var.tfc_agent_version}_SHA256SUMS",
      "mkdir /agent",
      "unzip tfc-agent_${var.tfc_agent_version}_linux_amd64.zip -d /agent",
      "rm tfc-agent_${var.tfc_agent_version}_SHA256SUMS",
      "rm tfc-agent_${var.tfc_agent_version}_SHA256SUMS.sig",
      "rm -f tfc-agent_${var.tfc_agent_version}_linux_amd64.zip"
    ]
  }

}
