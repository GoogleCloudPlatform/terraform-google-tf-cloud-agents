# Self Hosted Terraform Cloud Agent on Managed Instance Group Container VMs

This module handles the opinionated creation of infrastructure necessary to deploy Terraform Cloud Agents on MIG Container VMs.

This includes:

- Enabling necessary APIs
- VPC
- NAT & Cloud Router
- MIG Container Instance Template
- MIG Instance Manager
- FW Rules

Below are some examples:

## [Simple Self Hosted Terraform Cloud Agent](../../examples/tfc-agent-mig-container-vm-simple/README.md)

This example shows how to deploy a self hosted Terraform Cloud Agent on MIG Container VMs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_metadata | Additional metadata to attach to the instance | `map(any)` | `{}` | no |
| cooldown\_period | The number of seconds that the autoscaler should wait before it starts collecting information from a new instance. | `number` | `60` | no |
| create\_network | When set to true, VPC,router and NAT will be auto created | `bool` | `true` | no |
| dind | Flag to determine whether to expose dockersock | `bool` | `false` | no |
| image | The Terraform Agent image | `string` | `"hashicorp/tfc-agent:latest"` | no |
| network\_name | Name for the VPC network | `string` | `"tfc_agent_network"` | no |
| project\_id | The project id to deploy Terraform Agent | `string` | n/a | yes |
| region | The GCP region to deploy instances into | `string` | `"us-central1"` | no |
| restart\_policy | The desired Docker restart policy for the agent image | `string` | `"Always"` | no |
| service\_account | Service account email address | `string` | `""` | no |
| startup\_script | User startup script to run when instances spin up | `string` | `""` | no |
| subnet\_ip | IP range for the subnet | `string` | `"10.10.10.0/24"` | no |
| subnet\_name | Name for the subnet | `string` | `"tfc-agent-subnet"` | no |
| subnetwork\_project | The ID of the project in which the subnetwork belongs. If it is not provided, the project\_id is used. | `string` | `""` | no |
| target\_size | The number of Terraform Cloud Agent instances | `number` | `2` | no |
| tfc\_agent\_address | The HTTP or HTTPS address of the Terraform Cloud/Enterprise API. | `string` | `"https://app.terraform.io"` | no |
| tfc\_agent\_auto\_update | Controls automatic core updates behavior. Acceptable values include disabled, patch, and minor | `string` | `"minor"` | no |
| tfc\_agent\_name\_prefix | This name may be used in the Terraform Cloud user interface to help easily identify the agent | `string` | `"tfc-agent-container-vm"` | no |
| tfc\_agent\_single | Enable single mode. This causes the agent to handle at most one job and<br>immediately exit thereafter. Useful for running agents as ephemeral<br>containers, VMs, or other isolated contexts with a higher-level scheduler<br>or process supervisor. | `bool` | `false` | no |
| tfc\_agent\_token | Terraform Cloud agent token. (mark as sensitive) (TFC Organization Settings >> Agents) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| mig\_instance\_group | The instance group url of the created MIG |
| mig\_instance\_template | The name of the MIG Instance Template |
| mig\_name | The name of the MIG |
| network\_name | Name of VPC |
| service\_account | Service account email for GCE |
| subnet\_name | Name of VPC |

 <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

Before this module can be used on a project, you must ensure that the following pre-requisites are fulfilled:

1. Required APIs are activated

    ```text
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containerregistry.googleapis.com",
    "storage-component.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
    ```
