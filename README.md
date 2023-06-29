# terraform-google-terraform-cloud-agents

Creates self hosted Terraform Cloud Agents on Google Cloud. Using these Terraform modules you can quickly deploy agent pools for your Terraform Cloud workflows.

## [Terraform Cloud Agents on GKE](modules/tfc-agent-gke/README.md)

The `tfc-agent-gke` module provisions the resources required to deploy self hosted Terraform Cloud Agents on Google Cloud infrastructure using Google Kubernetes Engine (GKE).

This includes

- Enabling necessary APIs
- VPC
- GKE Cluster
- Kubernetes Secret

*Below are some examples:*

- [Terraform Cloud Agents on GKE](examples/tfc-agent-gke-simple/README.md) - This example shows how to deploy a simple GKE self hosted Terraform Cloud Agent.

## [Terraform Cloud Agents on Managed Instance Groups using VMs](modules/tfc-agent-mig-vm/README.md)

The `tfc-agent-mig-vm` module provisions the resources required to deploy Terrform Cloud Agent on Google Cloud infrastructure using Managed Instance Groups.

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

- [Terraform Cloud Agents on MIG VMs](examples/tfc-agent-mig-native-simple/README.md) - This example shows how to deploy a MIG Terraform Cloud Agent with startup scripts.

## [Terraform Cloud Agents Instance Groups using Container VMs](modules/tfc-agent-mig-container-vm/README.md)

The `tfc-agent-mig-container-vm` module provisions the resources required to deploy Terraform Cloud Agents on Google Cloud infrastructure using Managed Instance Groups and Container VMs.

This includes

- Enabling necessary APIs
- VPC
- NAT & Cloud Router
- MIG Container Instance Template
- MIG Instance Manager
- FW Rules

*Below are some examples:*

- [Terraform Cloud Agents on MIG Container VMs](examples/tfc-agent-mig-container-vm-simple/README.md) - This example shows how to deploy a Terraform Cloud Agent on MIG Container VMs.

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp]

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
