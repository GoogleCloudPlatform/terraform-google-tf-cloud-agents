# Simple Self Hosted Terraform Cloud agent on GKE

## Overview

This example shows how to deploy Terraform Cloud agents on Google Kubernetes Engine (GKE) using the `tfc-agent-gke` module.

It creates the Terraform Cloud agent pool, registers the agent to that pool and creates a project and an empty workspace with the agent attached.

## Prerequisites

The tools needed to build this example are available by default in Google Cloud Shell.

If running from your own system, you will need:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install-sdk)
  - [`gke-gcloud-auth-plugin`](https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke)

## Steps to deploy this example

1. Create terraform.tfvars file with the necessary values.

    The Terraform Cloud agent token you would like to use. NOTE: This is a secret and should be marked as sensitive in Terraform Cloud.

    ```tf
    project_id   = "your-project-id"
    tfc_org_name = "your-tfc-org-name"
    ```

1. Build the example Terraform Cloud agent image using Google Cloud Build. Alternatively, you can also use the [tfc-agent-gke-simple](../tfc-agent-gke-simple/README.md) for working with the default Terraform agent image.

    ```sh
    # Export required variables
    export PROJECT_ID="your-project-id"
    export LOCATION="us-west1"
    export REPOSITORY="hashicorp"
    export IMAGE="tfc-agent"
    export VERSION="latest"

    # GCP commands to enable services
    gcloud config set project $PROJECT_ID
    gcloud services enable cloudbuild.googleapis.com
    gcloud services enable artifactregistry.googleapis.com
    gcloud components update

    # Create the Google Artifact Repository for storing the agent
    gcloud artifacts repositories create $REPOSITORY --location="$LOCATION" --repository-format="DOCKER"

    # Build the custom Terraform Cloud agent image using Cloud Build
    gcloud builds submit --config=cloudbuild.yaml \
    --substitutions=_LOCATION="$LOCATION",_REPOSITORY="$REPOSITORY",_IMAGE="$IMAGE",_VERSION="$VERSION" .
    ```

1. Initialize the Terraform Cloud agent image for running Terraform.

    ```sh
    export TF_VAR_tfc_agent_image=$LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE:$VERSION
    ```

1. Create the infrastructure.

    ```sh
    terraform init
    terraform plan
    terraform apply
    ```

1. Your Terraform Cloud agents should become active at Organization Setting > Security > Agents.

1. Create additonal workspaces or use the existing workspace to run Terraform through the Terraform Cloud agent.[Click here for more info on running the workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_run#example-usage).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent cluster | `string` | n/a | yes |
| tfc\_agent\_image | The custom Terraform Cloud agent image to use | `string` | n/a | yes |
| tfc\_agent\_pool\_name | Terraform Cloud agent pool name to be created | `string` | `"tfc-agent-gke-custom-pool"` | no |
| tfc\_agent\_pool\_token\_description | Terraform Cloud agent pool token description | `string` | `"tfc-agent-gke-custom-pool-token"` | no |
| tfc\_org\_name | Terraform Cloud org name where the agent pool will be created | `string` | n/a | yes |
| tfc\_project\_name | Terraform Cloud project name to be created | `string` | `"GCP agents GKE custom"` | no |
| tfc\_workspace\_name | Terraform Cloud workspace name to be created | `string` | `"tfc-agent-gke-custom"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ca\_certificate | The cluster CA certificate (base64 encoded) |
| cluster\_name | GKE cluster name |
| kubernetes\_endpoint | The cluster endpoint |
| location | GKE cluster location |
| network\_name | Name of the VPC |
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent cluster |
| service\_account | The default service account used for TFC agent nodes |
| subnet\_name | Name of the subnet in the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
