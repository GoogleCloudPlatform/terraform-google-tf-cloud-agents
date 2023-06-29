# Copyright (c) HashiCorp, Inc.

terraform {
  required_version = ">= 0.13"
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = ">= 3.53, < 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.53, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3, < 4.0"
    }
  }

}
