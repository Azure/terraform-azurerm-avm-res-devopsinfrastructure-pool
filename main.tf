resource "azapi_resource" "managed_devops_pool" {
  type = "Microsoft.DevOpsInfrastructure/pools@2024-04-04-preview"
  body = {
    properties = {
      devCenterProjectResourceId = var.dev_center_project_resource_id
      maximumConcurrency         = var.maximum_concurrency
      organizationProfile = {
        kind              = var.organization_profile.kind
        organizations     = local.organization_profile.organizations
        permissionProfile = local.organization_profile.permission_profile
      }

      agentProfile = local.agent_profile

      fabricProfile = {
        sku = {
          name = var.fabric_profile_sku_name
        }
        images = [ for image in var.fabric_profile_images : {
          wellKnownImageName = image.well_known_image_name
          aliases = image.aliases
          buffer = image.buffer
          resourceId = image.resource_id
        } ]

        networkProfile = var.subnet_id != null ? {
          subnetId = var.subnet_id
        } : null
        osProfile = {
          logonType = "Service"
        }
        storageProfile = {
          osDiskStorageAccountType = var.fabric_profile_os_disk_storage_account_type
          dataDisks                = [ for data_disk in var.fabric_profile_data_disks : {
            diskSizeGiB = data_disk.disk_size_gigabytes
            caching = data_disk.caching
            driveLetter = data_disk.drive_letter
            storageAccountType = data_disk.storage_account_type
          } ]
        }
        kind = "Vmss"
      }
    }
  }
  location                  = var.location
  name                      = var.name
  parent_id                 = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  schema_validation_enabled = false
  tags                      = var.tags
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.managed_devops_pool.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.managed_devops_pool.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
