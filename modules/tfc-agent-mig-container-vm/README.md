# Self Hosted Terraform Cloud agent on Managed Instance Group Container VMs

This module handles the opinionated creation of infrastructure necessary to deploy Terraform Cloud agents on MIG Container VMs.

This includes:

- Enabling necessary APIs
- VPC
- NAT & Cloud Router
- MIG Container Instance Template
- MIG Instance Manager
- FW Rules

Below are some examples:

## [Simple Self Hosted Terraform Cloud agent](../../examples/tfc-agent-mig-container-vm-simple/README.md)

This example shows how to deploy a self hosted Terraform Cloud agent on MIG Container VMs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_metadata | Additional metadata to attach to the instance | `map(any)` | `{}` | no |
| autoscaling\_enabled | Set to true to enable autoscaling in the MIG | `bool` | `true` | no |
| cooldown\_period | The number of seconds that the autoscaler should wait before it<br>starts collecting information from a new instance. | `number` | `60` | no |
| create\_network | When set to true, VPC, router and NAT will be auto created | `bool` | `true` | no |
| create\_service\_account | Set to true to create a new service account, false to use an existing one | `bool` | `true` | no |
| dind | Flag to determine whether to expose dockersock | `bool` | `false` | no |
| image | The Terraform Cloud agent image | `string` | `"hashicorp/tfc-agent:latest"` | no |
| network\_name | Name for the VPC network. Only used if subnetwork\_project and subnet\_name are not specified | `string` | `"tfc-agent-network"` | no |
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent | `string` | n/a | yes |
| region | The GCP region to use when deploying resources | `string` | `"us-central1"` | no |
| restart\_policy | The desired Docker restart policy for the agent image | `string` | `"Always"` | no |
| service\_account\_email | Service account email address to use with the MIG template, required if create\_service\_account is set to false | `string` | `""` | no |
| startup\_script | User startup script to run when instances spin up | `string` | `""` | no |
| subnet\_ip | IP range for the subnet | `string` | `"10.10.10.0/24"` | no |
| subnet\_name | Name for the subnet | `string` | `"tfc-agent-subnet"` | no |
| subnetwork\_project | The project ID of the shared VPCs host (for shared vpc support).<br>If not provided, the project\_id is used | `string` | `""` | no |
| target\_size | The number of Terraform Cloud agent instances | `number` | `2` | no |
| tfc\_agent\_address | The HTTP or HTTPS address of the Terraform Cloud/Enterprise API | `string` | `"https://app.terraform.io"` | no |
| tfc\_agent\_auto\_update | Controls automatic core updates behavior. Acceptable values include disabled, patch, and minor | `string` | `"minor"` | no |
| tfc\_agent\_name\_prefix | This name may be used in the Terraform Cloud user interface to help easily identify the agent | `string` | `"tfc-agent-container-vm"` | no |
| tfc\_agent\_single | Enable single mode. This causes the agent to handle at most one job and<br>immediately exit thereafter. Useful for running agents as ephemeral<br>containers, VMs, or other isolated contexts with a higher-level scheduler<br>or process supervisor. | `bool` | `false` | no |
| tfc\_agent\_token | Terraform Cloud agent token. (Organization Settings >> Agents) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| mig\_instance\_group | The instance group url of the created MIG |
| mig\_instance\_template | The name of the MIG Instance Template |
| mig\_name | The name of the MIG |
| network\_name | Name of the VPC |
| service\_account\_email | Service account email attached to MIG templates for GCE |
| subnet\_name | Name of the subnet in the VPC |

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