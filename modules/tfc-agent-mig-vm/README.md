# Self Hosted Terraform Cloud agent on Managed Instance Group

This module handles the opinionated creation of infrastructure necessary to deploy Terraform Cloud agents on a Managed Instance Group (MIG).

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

## [Simple Self Hosted Terraform Cloud agent](../../examples/tfc-agent-mig-vm-simple/README.md)

This example shows how to deploy a MIG self hosted Terraform Cloud agent bootstrapped using startup scripts.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cooldown\_period | The number of seconds that the autoscaler should wait before it<br>starts collecting information from a new instance | `number` | `60` | no |
| create\_network | When set to true, VPC, router and NAT will be auto created | `bool` | `true` | no |
| create\_service\_account | Set to true to create a new service account, false to use an existing one | `bool` | `true` | no |
| custom\_metadata | User provided custom metadata | `map(any)` | `{}` | no |
| machine\_type | The GCP machine type to deploy | `string` | `"n1-standard-1"` | no |
| max\_replicas | Maximum number of Terraform agent instances | `number` | `10` | no |
| min\_replicas | Minimum number of Terraform agent instances | `number` | `1` | no |
| network\_name | Name for the VPC network | `string` | `"tfc-agent-network"` | no |
| network\_project | The project ID of the shared VPCs host (for shared vpc support).<br>If not provided, the project\_id is used | `string` | `""` | no |
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent | `string` | n/a | yes |
| region | The GCP region to use when deploying resources | `string` | `"us-central1"` | no |
| service\_account\_email | Service account email address to use with the MIG template, required if create\_service\_account is set to false | `string` | `""` | no |
| source\_image | Source disk image. If neither source\_image nor source\_image\_family is specified,<br>defaults to the latest public CentOS image | `string` | `""` | no |
| source\_image\_family | Source image family. If neither source\_image nor source\_image\_family<br>is specified, defaults to the latest public Ubuntu image | `string` | `"ubuntu-2204-lts"` | no |
| source\_image\_project | Project where the source image originates | `string` | `"ubuntu-os-cloud"` | no |
| startup\_script | User startup script to run when instances spin up | `string` | `""` | no |
| subnet\_ip | IP range for the subnet | `string` | `"10.10.10.0/24"` | no |
| subnet\_name | Name for the subnet | `string` | `"tfc-agent-subnet"` | no |
| tfc\_agent\_address | The HTTP or HTTPS address of the Terraform Cloud/Enterprise API | `string` | `"https://app.terraform.io"` | no |
| tfc\_agent\_auto\_update | Controls automatic core updates behavior.<br>Acceptable values include disabled, patch, and minor | `string` | `"minor"` | no |
| tfc\_agent\_labels | Terraform Cloud agent labels to attach to the VMs | `set(string)` | `[]` | no |
| tfc\_agent\_name\_prefix | This name may be used in the Terraform Cloud user interface to help<br>easily identify the agent | `string` | `"tfc-agent-mig-vm"` | no |
| tfc\_agent\_secret | The secret id for storing the Terraform Cloud agent secret | `string` | `"tfc-agent"` | no |
| tfc\_agent\_single | Enable single mode. This causes the agent to handle at most one job and<br>immediately exit thereafter. Useful for running agents as ephemeral<br>containers, VMs, or other isolated contexts with a higher-level scheduler<br>or process supervisor | `bool` | `false` | no |
| tfc\_agent\_token | Terraform Cloud agent token. (Organization Settings >> Agents) | `string` | n/a | yes |
| tfc\_agent\_version | Terraform Cloud Agent version to install | `string` | `"1.12.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| mig\_instance\_group | The instance group url of the created MIG |
| mig\_instance\_template | The name of the MIG Instance Template |
| mig\_name | The name of the MIG |
| network\_name | Name of the VPC |
| service\_account\_email | Service account email used with the MIG template |

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
