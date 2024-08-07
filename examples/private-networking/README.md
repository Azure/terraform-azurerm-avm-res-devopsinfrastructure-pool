<!-- BEGIN_TF_DOCS -->
# Example of deploying DevOps Managed Pools with Private Networking

This deploys the module with Private Networking for Azure Managed DevOps Pools.

There are some points of note for this example:

- There is a special built in service principal called `DevOpsInfrastructure` that is used to join the Managed DevOps Pool to the Virtual Network Subnet. This service principal must be granted role assignments to the virtual network and subnet for this to work. You can read more here: <https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-networking?view=azure-devops&tabs=azure-portal#to-check-the-devopsinfrastructure-principal-access>
- In the example we have created a custom role in order to demonstrate least privilege access, but you can also use the built in `Network Contributor` role.

```hcl
variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "The personal access token used for agent authentication to Azure DevOps."
  sensitive   = true
}

locals {
  tags = {
    scenario = "default"
  }
}

terraform {
  required_version = ">= 1.9"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.14"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  azure_devops_organization_url = "https://dev.azure.com/${var.azure_devops_organization_name}"
}

provider "azuredevops" {
  personal_access_token = var.azure_devops_personal_access_token
  org_service_url       = local.azure_devops_organization_url
}

resource "random_string" "name" {
  length  = 6
  numeric = true
  special = false
  upper   = false
}

resource "azuredevops_project" "this" {
  name = random_string.name.result
}

locals {
  default_branch  = "refs/heads/main"
  pipeline_file   = "pipeline.yml"
  repository_name = "example-repo"
}

resource "azuredevops_git_repository" "this" {
  project_id     = azuredevops_project.this.id
  name           = local.repository_name
  default_branch = local.default_branch
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_git_repository_file" "this" {
  repository_id = azuredevops_git_repository.this.id
  file          = local.pipeline_file
  content = templatefile("${path.module}/${local.pipeline_file}", {
    agent_pool_name = module.managed_devops_pool.name
  })
  branch              = local.default_branch
  commit_message      = "[skip ci]"
  overwrite_on_create = true
}

resource "azuredevops_build_definition" "this" {
  project_id = azuredevops_project.this.id
  name       = "Example Build Definition"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this.id
    branch_name = azuredevops_git_repository.this.default_branch
    yml_path    = local.pipeline_file
  }
}

data "azuredevops_agent_queue" "this" {
  project_id = azuredevops_project.this.id
  name       = module.managed_devops_pool.name
  depends_on = [module.managed_devops_pool]
}

resource "azuredevops_pipeline_authorization" "this" {
  project_id  = azuredevops_project.this.id
  resource_id = data.azuredevops_agent_queue.this.id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.this.id
}

resource "azurerm_resource_group" "this" {
  location = local.selected_region
  name     = "rg-${random_string.name.result}"
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = "law-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name
}

locals {
  resource_providers_to_register = {
    dev_center = {
      resource_provider = "Microsoft.DevCenter"
    }
    devops_infrastructure = {
      resource_provider = "Microsoft.DevOpsInfrastructure"
    }
  }
}

data "azurerm_client_config" "this" {}

resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  resource_id = "/subscriptions/${data.azurerm_client_config.this.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
}

resource "azurerm_role_definition" "this" {
  name        = "Virtual Network Contributor for DevOpsInfrastructure (${random_string.name.result})"
  scope       = azurerm_resource_group.this.id
  description = "Custom Role for Virtual Network Contributor for DevOpsInfrastructure (${random_string.name.result})"

  permissions {
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/validate/action",
      "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/write",
      "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/delete"
    ]
  }
}

data "azuread_service_principal" "this" {
  display_name = "DevOpsInfrastructure" # This is a special built in service principal (see: https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-networking?view=azure-devops&tabs=azure-portal#to-check-the-devopsinfrastructure-principal-access)
}

resource "azurerm_public_ip" "this" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.this.location
  name                = "pip-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "this" {
  location            = azurerm_resource_group.this.location
  name                = "nat-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this.id
}

module "virtual_network" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.4.0"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "vnet-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name
  role_assignments = {
    virtual_network_reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = data.azuread_service_principal.this.object_id
    }
    subnet_join = {
      role_definition_id_or_name = azurerm_role_definition.this.role_definition_resource_id
      principal_id               = data.azuread_service_principal.this.object_id
    }
  }
  subnets = {
    subnet0 = {
      name             = "subnet-${random_string.name.result}"
      address_prefixes = ["10.30.0.0/24"]
      delegation = [{
        name = "Microsoft.DevOpsInfrastructure.pools"
        service_delegation = {
          name = "Microsoft.DevOpsInfrastructure/pools"
        }
      }]
      nat_gateway = {
        id = azurerm_nat_gateway.this.id
      }
    }
  }
}

resource "azurerm_dev_center" "this" {
  location            = azurerm_resource_group.this.location
  name                = "dc-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name

  depends_on = [azapi_resource_action.resource_provider_registration]
}

resource "azurerm_dev_center_project" "this" {
  dev_center_id       = azurerm_dev_center.this.id
  location            = azurerm_resource_group.this.location
  name                = "dcp-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call
module "managed_devops_pool" {
  source                         = "../.."
  resource_group_name            = azurerm_resource_group.this.name
  location                       = azurerm_resource_group.this.location
  name                           = "mdp-${random_string.name.result}"
  dev_center_project_resource_id = azurerm_dev_center_project.this.id
  subnet_id                      = module.virtual_network.subnets["subnet0"].resource_id
  organization_profile = {
    organizations = [{
      name     = var.azure_devops_organization_name
      projects = [azuredevops_project.this.name]
    }]
  }
  /* diagnostic_settings = {
    sendToLogAnalytics = {
      name                           = "sendToLogAnalytics"
      workspace_resource_id          = azurerm_log_analytics_workspace.this.id
      log_analytics_destination_type = "Dedicated"
    }
  } */
  tags = local.tags
  depends_on = [
    azapi_resource_action.resource_provider_registration,
    module.virtual_network
  ]
}

output "managed_devops_pool_id" {
  value = module.managed_devops_pool.resource_id
}

output "managed_devops_pool_name" {
  value = module.managed_devops_pool.name
}

output "virtual_network_id" {
  value = module.virtual_network.resource_id
}

output "virtual_network_subnets" {
  value = module.virtual_network.subnets
}

# Region helpers
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.1.0"
}

resource "random_integer" "region_index" {
  max = length(local.regions) - 1
  min = 0
}

locals {
  excluded_regions = [
    "westeurope" # Capacity issues
  ]
  included_regions = [
    "australiaeast", "brazilsouth", "canadacentral", "centralus", "westeurope", "germanywestcentral", "italynorth", "japaneast", "uksouth", "eastus", "eastus2", "southafricanorth", "southcentralus", "southeastasia", "switzerlandnorth", "swedencentral", "westus3", "centralindia", "eastasia", "northeurope", "koreacentral"
  ]
  regions         = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name)]
  selected_region = "uksouth" # local.regions[random_integer.region_index.result]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.1)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.113)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource_action.resource_provider_registration](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) (resource)
- [azuredevops_build_definition.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition) (resource)
- [azuredevops_git_repository.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository) (resource)
- [azuredevops_git_repository_file.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository_file) (resource)
- [azuredevops_pipeline_authorization.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) (resource)
- [azuredevops_project.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/project) (resource)
- [azurerm_dev_center.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center) (resource)
- [azurerm_dev_center_project.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_center_project) (resource)
- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) (resource)
- [azurerm_nat_gateway_public_ip_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) (resource)
- [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) (data source)
- [azuredevops_agent_queue.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/agent_queue) (data source)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_azure_devops_organization_name"></a> [azure\_devops\_organization\_name](#input\_azure\_devops\_organization\_name)

Description: Azure DevOps Organisation Name

Type: `string`

### <a name="input_azure_devops_personal_access_token"></a> [azure\_devops\_personal\_access\_token](#input\_azure\_devops\_personal\_access\_token)

Description: The personal access token used for agent authentication to Azure DevOps.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_managed_devops_pool_id"></a> [managed\_devops\_pool\_id](#output\_managed\_devops\_pool\_id)

Description: n/a

### <a name="output_managed_devops_pool_name"></a> [managed\_devops\_pool\_name](#output\_managed\_devops\_pool\_name)

Description: n/a

### <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id)

Description: n/a

### <a name="output_virtual_network_subnets"></a> [virtual\_network\_subnets](#output\_virtual\_network\_subnets)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_managed_devops_pool"></a> [managed\_devops\_pool](#module\_managed\_devops\_pool)

Source: ../..

Version:

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: 0.1.0

### <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: 0.4.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->