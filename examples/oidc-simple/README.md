# OIDC Simple Example

## Overview

This example showcases how to configure [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) using the [tfc-oidc module](../../modules/tfc-oidc/README.md) for a sample Service Account.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project id to create Workload Identity Federation pool and example Service Account | `string` | n/a | yes |
| role\_list | Google Cloud roles required for the Service Account | `list(string)` | <pre>[<br>  "roles/storage.admin"<br>]</pre> | no |
| tfc\_org\_name | Terraform Cloud org name where the Workload Identity Federation pool will be attached | `string` | n/a | yes |
| tfc\_project\_name | Terraform Cloud project name where the Workload Identity Federation pool will be attached | `string` | `"GCP OIDC"` | no |
| tfc\_workspace\_name | Terraform Cloud workspace name where the Workload Identity Federation pool will be attached | `string` | `"gcp-oidc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| pool\_name | Pool name |
| project\_id | The project id to create Workload Identity Federation pool and example Service Account |
| provider\_name | Provider name |
| sa\_email | Example SA email |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
