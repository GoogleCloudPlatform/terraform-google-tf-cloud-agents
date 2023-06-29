# Simple Self Hosted Terraform Cloud Agent on GKE

## Overview

This example shows how to deploy Terraform Cloud Agents on Google Kubernetes Engine (GKE) using the `tfc-agent-gke` module.

It creates the Terraform Cloud agent pool, registers the agent to that pool and creates a project and an empty workspace with the agent attached.

## Prerequisites

The tools needed to build this example are available by default in Google Cloud Shell.

If running from your own system, you will need:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install-sdk)
  - [`gke-gcloud-auth-plugin`](https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke)
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)

## Steps to deploy this example

1. Create terraform.tfvars file with the necessary values.

    The Terraform Cloud agent token you would like to use. NOTE: This is a secret and should be marked as sensitive in Terraform Cloud.

    ```tf
    project_id      = "your-project-id"
    tfc_agent_token = "your-tfc-agent-token"
    ```

1. Create the infrastructure.

    ```sh
    terraform init
    terraform plan
    terraform apply
    ```

1. Build the example Terraform Cloud agent image using Google Cloud Build. Alternatively, you can also use a prebuilt image or build using a local docker daemon.

    ```sh
    export PROJECT_ID="your-project-id"
    gcloud config set project $PROJECT_ID
    gcloud services enable cloudbuild.googleapis.com
    gcloud builds submit --config=cloudbuild.yaml
    ```

1. Replace image in [sample k8s deployment manifest](./sample-manifests/deployment.yaml).

    ```sh
    kustomize edit set image gcr.io/PROJECT_ID/tfc-agent:latest=gcr.io/$PROJECT_ID/tfc-agent:latest
    ```

1. Generate kubeconfig and apply the manifests for Deployment and HorizontalPodAutoscaler.

    ```sh
    gcloud container clusters get-credentials $(terraform output -raw cluster_name)
    kustomize build . | kubectl apply -f -
    ```

1. Your Terraform Cloud Agents should become active at Organization Setting > Security > Agents.

1. Create additonal workspaces or use the existing workspace to run Terraform through the Terraform Cloud Agent.[Click here for more info on running the workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_run#example-usage).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project id to deploy Terraform Cloud Agent | `string` | n/a | yes |
| tfc\_agent\_pool\_name | Terraform Cloud Agent pool name to be created | `string` | `"tfc-agent-gke-simple-pool"` | no |
| tfc\_agent\_pool\_token | Terraform Cloud Agent pool token description | `string` | `"tfc-agent-gke-simple-pool-token"` | no |
| tfc\_org\_name | Terraform Cloud org name where the agent pool will be created | `string` | n/a | yes |
| tfc\_project\_name | Terraform Cloud project name to be created | `string` | `"GCP Agents GKE"` | no |
| tfc\_workspace\_name | Terraform Cloud workspace name to be created | `string` | `"tfc-agent-gke-simple"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ca\_certificate | The cluster ca certificate (base64 encoded) |
| client\_token | The bearer token for auth |
| cluster\_name | Cluster name |
| kubernetes\_endpoint | The cluster endpoint |
| location | Cluster location |
| network\_name | Name of VPC |
| service\_account | The default service account used for running nodes. |
| subnet\_name | Name of VPC |

 <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
