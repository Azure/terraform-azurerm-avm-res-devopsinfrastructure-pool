resource "azapi_resource" "mdp" {
  type = "Microsoft.DevOpsInfrastructure/pools@2024-04-04-preview"
  body = {
    properties = {
      devCenterProjectResourceId = var.devCenterProjectResourceId
      maximumConcurrency         = var.maximumConcurrency
      organizationProfile = {
        kind              = "AzureDevOps"
        organizations     = local.organizationProfile.organizations
        permissionProfile = local.organizationProfile.permissionProfile
      }

      agentProfile = local.agentProfile

      fabricProfile = {
        sku = {
          name = var.fabricProfileSkuName
        }
        images = var.fabricProfileImages

        networkProfile = var.subnetId != null ? {
          subnetId = var.subnetId
        } : null
        osProfile = {
          logonType = "Service"
        }
        storageProfile = {
          osDiskStorageAccountType = var.fabricProfileOsDiskStorageAccountType
          dataDisks                = var.fabricProfileDataDisks
        }
        kind = "Vmss"
      }
    }
  }
  location                  = var.location
  name                      = var.name
  parent_id                 = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  schema_validation_enabled = true
  tags                      = var.tags
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.mdp.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.mdp.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
