## Terraform Cloud OIDC (Dynamic Credentials)

This module handles the opinionated creation of infrastructure necessary to configure [Workload Identity pools](https://cloud.google.com/iam/docs/workload-identity-federation#pools) and [providers](https://cloud.google.com/iam/docs/workload-identity-federation#providers) for authenticating to GCP using [Terraform Cloud Dynamic Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/gcp-configuration).

This includes:

- Creation of a Workload Identity pool
- Configuring a Workload Identity provider
- Granting external identities necessary IAM roles on Service Accounts

### Example Usage

```terraform
module "tfc_oidc" {
  source      = "terraform-google-modules/terraform-cloud-agents/google//modules/tfc-oidc"
  project_id  = var.project_id
  pool_id     = "example-pool"
  provider_id = "example-tfc-provider"
  sa_mapping = {
    "foo-service-account" = {
      sa_name   = "projects/my-project/serviceAccounts/foo-service-account@my-project.iam.gserviceaccount.com"
      sa_email  = "foo-service-account@my-project.iam.gserviceaccount.com"
      attribute = "attribute.repository/${USER/ORG}/<repo>"
    }
  }
  tfc_organization_name = "example-tfc-organization"
  tfc_workspace_name = "example-tfc-workspace-name"
}
```

Below are some examples:

### [OIDC Simple](../../examples/oidc-simple/README.md)

This example shows how to use this module along with a Service Account to access storage buckets.

### Terraform Cloud Workflow

Once provisioned, you can use the `example-tfc-workspace-name` workspace from the example above to provision any infrastructure that the Service Account has access for.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_audiences | Workload Identity Pool Provider allowed audiences | `list(string)` | `[]` | no |
| attribute\_condition | Workload Identity Pool Provider attribute condition expression<br>For more info please see<br>https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider | `string` | `""` | no |
| attribute\_mapping | Workload Identity Pool Provider attribute mapping<br>For more info please see<br>https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider | `map(any)` | <pre>{<br>  "attribute.aud": "assertion.aud",<br>  "attribute.terraform_full_workspace": "assertion.terraform_full_workspace",<br>  "attribute.terraform_organization_id": "assertion.terraform_organization_id",<br>  "attribute.terraform_organization_name": "assertion.terraform_organization_name",<br>  "attribute.terraform_project_id": "assertion.terraform_project_id",<br>  "attribute.terraform_project_name": "assertion.terraform_project_name",<br>  "attribute.terraform_run_id": "assertion.terraform_run_id",<br>  "attribute.terraform_run_phase": "assertion.terraform_run_phase",<br>  "attribute.terraform_workspace_id": "assertion.terraform_workspace_id",<br>  "attribute.terraform_workspace_name": "assertion.terraform_workspace_name",<br>  "google.subject": "assertion.sub"<br>}</pre> | no |
| issuer\_uri | Workload Identity Pool Issuer URL for Terraform Cloud/Enterprise.<br>The default audience format used by TFC is of the form<br>//iam.googleapis.com/projects/{project\_id}/locations/global/workloadIdentityPools/{pool\_id}/providers/{provider\_id}<br>which matches with the default accepted audience format on GCP | `string` | `"https://app.terraform.io"` | no |
| pool\_description | Workload Identity Pool description | `string` | `"Workload Identity Pool managed by Terraform"` | no |
| pool\_display\_name | Workload Identity Pool display name | `string` | `null` | no |
| pool\_id | Workload Identity Pool ID | `string` | n/a | yes |
| project\_id | The Google Cloud Platform project ID to use | `string` | n/a | yes |
| provider\_description | Workload Identity Pool Provider description | `string` | `"Workload Identity Pool Provider managed by Terraform"` | no |
| provider\_display\_name | Workload Identity Pool Provider display name | `string` | `null` | no |
| provider\_id | Workload Identity Pool Provider ID | `string` | n/a | yes |
| sa\_mapping | Service Account resource names and corresponding WIF provider attributes.<br>If attribute is set to `*` all identities in the pool are granted access to SAs | <pre>map(object({<br>    sa_name   = string<br>    sa_email  = string<br>    attribute = string<br>  }))</pre> | `{}` | no |
| service\_list | Google Cloud APIs required for the project | `list(string)` | <pre>[<br>  "iam.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "sts.googleapis.com",<br>  "iamcredentials.googleapis.com"<br>]</pre> | no |
| tfc\_organization\_name | The Terraform Cloud organization to use | `string` | n/a | yes |
| tfc\_project\_name | The Terraform Cloud project to use | `string` | `"Default Project"` | no |
| tfc\_workspace\_name | The Terraform Cloud workspace to authorize via OIDC | `string` | `"gcp-oidc-workspace"` | no |

## Outputs

| Name | Description |
|------|-------------|
| pool\_name | Pool name |
| provider\_name | Provider name |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

Before this module can be used on a project, you must ensure that the following pre-requisites are fulfilled:

1. Required APIs are activated

    ```
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com"
    ```

1. Service Account used to deploy this module has the following roles

    ```
    roles/iam.workloadIdentityPoolAdmin
    roles/iam.serviceAccountAdmin
    ```
