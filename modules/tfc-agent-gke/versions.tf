# Copyright (c) HashiCorp, Inc.

terraform {
  required_version = ">= 0.13"
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = ">= 4.3.0, < 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3, < 4.0"
    }
  }

}
