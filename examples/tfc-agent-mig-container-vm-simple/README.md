# Example Terraform Cloud agent on MIG Container VM

## Overview

This example shows how to deploy a Terraform Cloud agent on Google Compute Engine Container VMs using the `tfc-agent-mig-container-vm` module.

It creates the Terraform Cloud agent pool, registers the agent to that pool and creates a project and an empty workspace with the agent attached.

## Steps to deploy this example

1. Create terraform.tfvars file with the necessary values.

    The Terraform Cloud agent token you would like to use. NOTE: This is a secret and should be marked as sensitive in Terraform Cloud.

    ```tf
    project_id   = "your-project-id"
    tfc_org_name = "your-tfc-org-name"
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
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent MIG | `string` | n/a | yes |
| tfc\_agent\_pool\_name | Terraform Cloud agent pool name to be created | `string` | `"tfc-agent-mig-container-vm-simple-pool"` | no |
| tfc\_agent\_pool\_token\_description | Terraform Cloud agent pool token description | `string` | `"tfc-agent-mig-container-vm-simple-pool-token"` | no |
| tfc\_org\_name | Terraform Cloud org name where the agent pool will be created | `string` | n/a | yes |
| tfc\_project\_name | Terraform Cloud project name to be created | `string` | `"GCP agents Container VM"` | no |
| tfc\_workspace\_name | Terraform Cloud workspace name to be created | `string` | `"tfc-agent-mig-container-vm-simple"` | no |

## Outputs

| Name | Description |
|------|-------------|
| mig\_instance\_group | The instance group url of the created MIG |
| mig\_instance\_template | The name of the MIG Instance Template |
| mig\_name | The name of the MIG |
| service\_account | Service account email used with the MIG template |

 <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
