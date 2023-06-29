# Example Terraform Cloud Agent on Managed Instance Group

## Overview

This example showcases how to use startup scripts to deploy a Terraform Cloud Agent using the `tfc-agent-mig-vm` module.

It creates the Terraform Cloud agent pool, registers the agent to that pool and creates a project and an empty workspace with the agent attached using startup/shutdown scripts to install the Terraform Cloud Agent binary, register the agent when it comes online.

## Steps to deploy this example

1. Create terraform.tfvars file with the necessary values. The Terraform Cloud agent token you would like to use. NOTE: This is a secret and should be marked as sensitive in Terraform Cloud.

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

1. Your Terraform Cloud Agents should become active at Organization Setting > Security > Agents.

1. Create additonal workspaces or use the existing workspace to run Terraform through the Terraform Cloud Agent.[Click here for more info on running the workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_run#example-usage).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project id to deploy Terraform Cloud Agent MIG | `string` | n/a | yes |
| tfc\_agent\_pool\_name | Terraform Cloud Agent pool name to be created | `string` | `"tfc-agent-mig-vm-simple-pool"` | no |
| tfc\_agent\_pool\_token | Terraform Cloud Agent pool token description | `string` | `"tfc-agent-mig-vm-simple-pool-token"` | no |
| tfc\_org\_name | Terraform Cloud org name where the agent pool will be created | `string` | n/a | yes |
| tfc\_project\_name | Terraform Cloud project name to be created | `string` | `"GCP Agents VM"` | no |
| tfc\_workspace\_name | Terraform Cloud workspace name to be created | `string` | `"tfc-agent-mig-vm-simple"` | no |

## Outputs

| Name | Description |
|------|-------------|
| mig\_instance\_group | The instance group url of the created MIG |
| mig\_instance\_template | The name of the MIG Instance Template |
| mig\_name | The name of the MIG |
| service\_account | Service account email for GCE |

 <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
