# Self Hosted Terraform Cloud Agent on Managed Instance Group

This module handles the opinionated creation of infrastructure necessary to deploy Terraform Cloud Agents on a Managed Instance Group (MIG).

This includes:

- Enabling necessary APIs
- VPC
- NAT & Cloud Router
- Service Account for MIG
- MIG Instance Template
- MIG Instance Manager
- FW Rules
- Secret Manager Secret

Below are some examples:

## [Simple Self Hosted Terraform Cloud Agent](../../examples/tfc-agent-mig-vm-simple/README.md)

This example shows how to deploy a MIG self hosted Terraform Cloud Agent bootstrapped using startup scripts.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cooldown\_period | The number of seconds that the autoscaler should wait before it starts collecting information from a new instance. | `number` | `60` | no |
| create\_network | When set to true, VPC,router and NAT will be auto created | `bool` | `true` | no |
| create\_subnetwork | Whether to create subnetwork or use the one provided via subnet\_name | `bool` | `true` | no |
| custom\_metadata | User provided custom metadata | `map(any)` | `{}` | no |
| machine\_type | The GCP machine type to deploy | `string` | `"n1-standard-1"` | no |
| max\_replicas | Maximum number of Terraform Agent instances | `number` | `10` | no |
| min\_replicas | Minimum number of Terraform Agent instances | `number` | `1` | no |
| network\_name | Name for the VPC network | `string` | `"tfc_agent_network"` | no |
| project\_id | The project id to deploy Terraform Cloud Agent | `string` | n/a | yes |
| region | The GCP region to deploy instances into | `string` | `"us-central1"` | no |
| service\_account | Service account email address | `string` | `""` | no |
| source\_image | Source disk image. If neither source\_image nor source\_image\_family is specified, defaults to the latest public CentOS image. | `string` | `""` | no |
| source\_image\_family | Source image family. If neither source\_image nor source\_image\_family is specified, defaults to the latest public Ubuntu image. | `string` | `"ubuntu-2204-lts"` | no |
| source\_image\_project | Project where the source image comes from | `string` | `"ubuntu-os-cloud"` | no |
| startup\_script | User startup script to run when instances spin up | `string` | `""` | no |
| subnet\_ip | IP range for the subnet | `string` | `"10.10.10.0/24"` | no |
| subnet\_name | Name for the subnet | `string` | `"tfc-agent-subnet"` | no |
| subnetwork\_project | The ID of the project in which the subnetwork belongs. If it is not provided, the project\_id is used. | `string` | `""` | no |
| tfc\_agent\_address | The HTTP or HTTPS address of the Terraform Cloud/Enterprise API. | `string` | `"https://app.terraform.io"` | no |
| tfc\_agent\_auto\_update | Controls automatic core updates behavior. Acceptable values include disabled, patch, and minor | `string` | `"minor"` | no |
| tfc\_agent\_labels | Terraform Cloud Agent labels to attach to the VMs | `set(string)` | `[]` | no |
| tfc\_agent\_name\_prefix | This name may be used in the Terraform Cloud user interface to help easily identify the agent | `string` | `"tfc_agent_mig-vm"` | no |
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
    "compute.googleapis.com",
    "storage-component.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    ```
