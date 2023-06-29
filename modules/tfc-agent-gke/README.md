# Self Hosted Terraform Cloud Agent on GKE

This module handles the opinionated creation of infrastructure necessary to deploy Terraform Cloud Agents on Google Kubernetes Engine (GKE).

This includes:

- Enabling necessary APIs
- VPC
- GKE Cluster
- Kubernetes Secret

Below are some examples:

## [Simple Self Hosted Terraform Cloud Agent on GKE](../../examples/tfc-agent-gke-simple/README.md)

This example shows how to deploy a simple GKE self hosted Terraform Cloud Agent.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_network | When set to true, VPC will be auto created | `bool` | `true` | no |
| ip\_range\_pods\_cidr | The secondary ip range cidr to use for pods | `string` | `"192.168.0.0/18"` | no |
| ip\_range\_pods\_name | The secondary ip range to use for pods | `string` | `"ip-range-pods"` | no |
| ip\_range\_services\_cider | The secondary ip range cidr to use for services | `string` | `"192.168.64.0/18"` | no |
| ip\_range\_services\_name | The secondary ip range to use for services | `string` | `"ip-range-scv"` | no |
| machine\_type | Machine type for TFC agent node pool | `string` | `"n1-standard-4"` | no |
| max\_node\_count | Maximum number of nodes in the TFC agent node pool | `number` | `4` | no |
| min\_node\_count | Minimum number of nodes in the TFC agent node pool | `number` | `2` | no |
| network\_name | Name for the VPC network | `string` | `"tfc_agent_network"` | no |
| project\_id | The project id to deploy Terraform Cloud Agent cluster | `string` | n/a | yes |
| region | The GCP region to deploy instances into | `string` | `"us-central1"` | no |
| service\_account | Optional Service Account for the nodes | `string` | `""` | no |
| subnet\_ip | IP range for the subnet | `string` | `"10.0.0.0/17"` | no |
| subnet\_name | Name for the subnet | `string` | `"tfc-agent-subnet"` | no |
| subnetwork\_project | The ID of the project in which the subnetwork belongs. If it is not provided, the project\_id is used. | `string` | `""` | no |
| tfc\_agent\_address | The HTTP or HTTPS address of the Terraform Cloud/Enterprise API. | `string` | `"https://app.terraform.io"` | no |
| tfc\_agent\_auto\_update | Controls automatic core updates behavior. Acceptable values include disabled, patch, and minor | `string` | `"minor"` | no |
| tfc\_agent\_k8s\_secrets | Name for the k8s secret required to configure TFC agent on GKE | `string` | `"tfc-agent-k8s-secrets"` | no |
| tfc\_agent\_name\_prefix | This name may be used in the Terraform Cloud user interface to help easily identify the agent | `string` | `"tfc-agent-k8s"` | no |
| tfc\_agent\_single | Enable single mode. This causes the agent to handle at most one job and<br>immediately exit thereafter. Useful for running agents as ephemeral<br>containers, VMs, or other isolated contexts with a higher-level scheduler<br>or process supervisor. | `bool` | `false` | no |
| tfc\_agent\_token | Terraform Cloud agent token. (mark as sensitive) (TFC Organization Settings >> Agents) | `string` | n/a | yes |
| zones | The GCP zone to deploy gke into | `list(string)` | <pre>[<br>  "us-central1-a"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| ca\_certificate | The cluster ca certificate (base64 encoded) |
| client\_token | The bearer token for auth |
| cluster\_name | Cluster name |
| kubernetes\_endpoint | The cluster endpoint |
| location | Cluster location |
| network\_name | Name of VPC |
| service\_account | The default service account used for TFC agent nodes. |
| subnet\_name | Name of VPC |

 <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

Before this module can be used on a project, you must ensure that the following pre-requisites are fulfilled:

1. Required APIs are activated

    ```text
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "storage-component.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
    ```
