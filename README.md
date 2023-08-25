# terraform-google-terraform-cloud-agents

Creates self hosted Terraform Cloud agents on Google Cloud. Using these Terraform modules you can quickly deploy agent pools for your Terraform Cloud workflows.

## [Terraform Cloud agents on GKE](modules/tfc-agent-gke/README.md)

The `tfc-agent-gke` module provisions the resources required to deploy self hosted Terraform Cloud agents on Google Cloud infrastructure using Google Kubernetes Engine (GKE).

This includes

- Enabling necessary APIs
- VPC
- GKE Cluster
- Kubernetes Secret

*Below are some examples:*

- [Terraform Cloud agents on GKE](examples/tfc-agent-gke-simple/README.md) - This example shows how to deploy the Terraform Cloud agent on GKE.
- [Terraform Cloud agents on GKE with a custom image](examples/tfc-agent-gke-custom/README.md) - This example shows how to deploy a custom built Terraform Cloud agent image on GKE.

## [Terraform Cloud agents on Managed Instance Groups using VMs](modules/tfc-agent-mig-vm/README.md)

The `tfc-agent-mig-vm` module provisions the resources required to deploy Terrform Cloud agent on Google Cloud infrastructure using Managed Instance Groups (MIG).

This includes

- Enabling necessary APIs
- VPC
- NAT & Cloud Router
- Service Account for MIG
- MIG Instance Template
- MIG Instance Manager
- FW Rules
- Secret Manager Secret

Deployment of Managed Instance Groups requires a [Google VM image](https://cloud.google.com/compute/docs/images) with a startup script that downloads and configures the agent or a pre-baked image with the agent installed.

*Below are some examples:*

- [Terraform Cloud agents on MIG VMs](examples/tfc-agent-mig-vm-simple/README.md) - This example shows how to deploy the Terraform Cloud agent on MIG with startup scripts.
- [Terraform Cloud agents on MIG VMs from Packer image](examples/tfc-agent-mig-vm-packer/README.md) - This example shows how to deploy the Terraform Cloud agent with an image pre-baked using Packer.

## [Terraform Cloud agents Instance Groups using Container VMs](modules/tfc-agent-mig-container-vm/README.md)

The `tfc-agent-mig-container-vm` module provisions the resources required to deploy Terraform Cloud agents on Google Cloud infrastructure using Managed Instance Groups and Container VMs.

This includes

- Enabling necessary APIs
- VPC
- NAT & Cloud Router
- MIG Container Instance Template
- MIG Instance Manager
- FW Rules

*Below are some examples:*

- [Terraform Cloud agents on MIG Container VMs](examples/tfc-agent-mig-container-vm-simple/README.md) - This example shows how to deploy a Terraform Cloud agent on MIG Container VMs.

## [Terraform Cloud OIDC (Dynamic Credentials)](modules/tfc-oidc/README.md)

The `tfc-oidc` module handles the opinionated creation of infrastructure necessary to configure [Workload Identity pools](https://cloud.google.com/iam/docs/workload-identity-federation#pools) and [providers](https://cloud.google.com/iam/docs/workload-identity-federation#providers) for authenticating to GCP using [Terraform Cloud Dynamic Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/gcp-configuration).

This includes

- Enabling necessary APIs
- Creation of a Workload Identity pool
- Configuring a Workload Identity provider
- Granting external identities necessary IAM roles on Service Accounts

*Below are some examples:*

- [OIDC Simple](examples/oidc-simple/README.md) - This example shows how to use this module along with a Service Account to access storage buckets.

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies might be required based on the module being used:

- [Terraform CLI][terraform-cli]
- [Terraform Provider for GCP][terraform-provider-gcp]
- [Terraform Provider for GCP beta][terraform-provider-gcp-beta]
- [Google Cloud CLI][gcloud-cli]
- [Kubernetes Provider][k8s-provider]
- [Random Provider][random-provider]

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform-provider-gcp-beta]: https://registry.terraform.io/providers/hashicorp/google-beta/latest
[terraform-cli]: https://www.terraform.io/downloads.html
[gcloud-cli]: https://cloud.google.com/sdk/gcloud
[k8s-provider]: https://registry.terraform.io/providers/hashicorp/kubernetes/latest
[random-provider]: https://registry.terraform.io/providers/hashicorp/random/latest

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
