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

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
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

module "vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.4.0"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = "vnet-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name
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
    }
  }
}

locals {
  role_assignment_for_network_resources = {
    "Network Contributor" = module.vnet.resource_id
    "Reader"              = module.vnet.resource_id
  }
}

data "azuread_service_principal" "this" {
  display_name = "DevOpsInfrastructure"
}

resource "azurerm_role_assignment" "name" {
  for_each = local.role_assignment_for_network_resources

  principal_id         = data.azuread_service_principal.this.object_id
  scope                = each.value
  role_definition_name = each.key
}

resource "time_sleep" "this" {
  create_duration = "30s"

  depends_on = [azurerm_role_assignment.name]
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
  name                           = random_string.name.result
  dev_center_project_resource_id = azurerm_dev_center_project.this.id
  subnet_id                      = module.vnet.subnets["subnet0"].resource_id
  organization_profile = {
    organizations = [{
      name     = var.azure_devops_organization_name
      projects = [azuredevops_project.this.name]
    }]
  }
  tags       = local.tags
  depends_on = [azapi_resource_action.resource_provider_registration, time_sleep.this]
}

output "managed_devops_pool_id" {
  value = module.managed_devops_pool.resource_id
}

output "managed_devops_pool_name" {
  value = module.managed_devops_pool.name
}

output "virtual_network_id" {
  value = module.vnet.resource_id
}

output "virtual_network_subnets" {
  value = module.vnet.subnets
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
    "australiaeast", "southeastasia", "westus", "westus2", "westus3", "brazilsouth", "centralindia", "eastasia", "eastus", "eastus2", "canadacentral", "centralus", "northcentralus", "southcentralus", "westcentralus", "northeurope", "westeurope", "uksouth"
  ]
  regions         = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name)]
  selected_region = "eastus" # local.regions[random_integer.region_index.result]
}
