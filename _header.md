# Azure Verified Module for Managed DevOps Pools

>**⚠️WARNING!⚠️**: THIS IS A PREVIEW SERVICE, MICROSOFT MAY NOT PROVIDE SUPPORT FOR THIS, PLEASE CHECK THE PRODUCT DOCS FOR CLARIFICATION

This module deploys and configures Managed DevOps Pools.

## Features

This module allows you to deploy Managed DevOps Pools with the following features:

- Public or Private Networking
- Multiple Agent Images
- Manual and Automatic Standby Agent Scaling

## Usage

This example deploys a Managed DevOps Pool with private networking.

```hcl
module "managed_devops_pool" {
  source                                   = "Azure/avm-res-devopsinfrastructure-pool/azurerm"
  resource_group_name                      = "my-resource-group"
  location                                 = "uksouth"
  name                                     = "my-managed-devops-pool"
  dev_center_project_resource_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group/providers/Microsoft.DevCenter/Projects/my-project"
  version_control_system_organization_name = "my-organization"
  version_control_system_project_names     = ["my-project"]
  subnet_id                                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
}
```
