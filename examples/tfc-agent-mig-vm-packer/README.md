# Example Terraform Cloud agent from Packer image

## Overview

This example showcases how to use Packer to pre-bake a Google VM Image with the necessary toolchain including Terraform Cloud agent and deploy this image using the `tfc-agent-mig` module.

We use startup script to register the runner when it comes online.

In this example, Packer creates a VM image that has the following:

- curl
- jq
- Terraform Cloud agent

## Steps to deploy this example

1. Give Cloud Build Service Account necessary permissions to create a new GCE VM Image using Packer.

   ```sh
   # Export required variables
   export PROJECT_ID="your_gcp_project_id"
   export TFC_AGENT_VERSION="1.12.0"

   # GCP commands to enable services
   gcloud config set project $PROJECT_ID
   gcloud services enable compute.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   gcloud components update

   # Configure the Service Account for the Google Cloud Build
   export CLOUD_BUILD_ACCOUNT=$(gcloud projects get-iam-policy $PROJECT_ID --filter="(bindings.role:roles/cloudbuild.builds.builder)"  --flatten="bindings[].members" --format="value(bindings.members[])")

   gcloud projects add-iam-policy-binding $PROJECT_ID --member $CLOUD_BUILD_ACCOUNT --role roles/compute.instanceAdmin.v1

   gcloud projects add-iam-policy-binding $PROJECT_ID --member $CLOUD_BUILD_ACCOUNT --role roles/iam.serviceAccountUser
   ```

1. Build GCE VM image. When the build finishes, the image id of the form `tfc-agent-image-*` will be displayed. We will use this in the tfvars we create in the next step.

   ```sh
   gcloud builds submit --config=cloudbuild.yaml --substitutions=_TFC_AGENT_VERSION="$TFC_AGENT_VERSION"
   ```

1. Create terraform.tfvars file with the necessary values.

   ```tf
   project_id   = "your-project-id"
   tfc_org_name = "your-tfc-org-name"
   source_image = "image-name-from-prev-step"
   ```

1. Create the infrastructure

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
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent MIG | `string` | n/a | yes |
| source\_image | Source disk image | `string` | n/a | yes |
| source\_image\_project | Project where the source image comes from | `string` | `null` | no |
| tfc\_agent\_pool\_name | Terraform Cloud agent pool name to be created | `string` | `"tfc-agent-mig-vm-packer-pool"` | no |
| tfc\_agent\_pool\_token\_description | Terraform Cloud agent pool token description | `string` | `"tfc-agent-mig-vm-packer-pool-token"` | no |
| tfc\_org\_name | Terraform Cloud org name where the agent pool will be created | `string` | n/a | yes |
| tfc\_project\_name | Terraform Cloud project name to be created | `string` | `"GCP agents"` | no |
| tfc\_workspace\_name | Terraform Cloud workspace name to be created | `string` | `"tfc-agent-mig-vm-packer"` | no |

## Outputs

| Name | Description |
|------|-------------|
| mig\_instance\_group | The instance group url of the created MIG |
| mig\_instance\_template | The name of the MIG Instance Template |
| mig\_name | The name of the MIG |
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent MIG |
| service\_account\_email | Service account email for GCE used with the MIG template |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
