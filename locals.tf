# TODO: insert locals here.
locals {
  agentProfile = merge(local.agentProfileBase, local.agentProfileStateful)
  # Workaround to avoid Payload API Spec Validation error, having gracePeriodTimeSpan and maxAgentLifetime in the agentProfile object, even though they had Null value.
  agentProfileBase = {
    kind                       = var.agentProfileKind
    resourcePredictionsProfile = local.resourcePredictionsProfile
    resourcePredictions = var.agentProfileResourcePredictionProfile == "Manual" ? {
      timeZone = var.agentProfileResourcePredictionsManual.timeZone
      daysData = local.daysData
    } : null
  }
  agentProfileStateful = var.agentProfileKind == "Stateful" ? {
    gracePeriodTimeSpan = var.agentProfileGracePeriodTimeSpan
    maxAgentLifetime    = var.agentProfileMaxAgentLifetime
  } : {}
  daysData = [
    # Sunday
    length(keys(var.agentProfileResourcePredictionsManual.sunday)) == 0 || var.agentProfileResourcePredictionsManual.sunday.startTime == null ? {} : {
      "${var.agentProfileResourcePredictionsManual.sunday.startTime}" = var.agentProfileResourcePredictionsManual.sunday.provisioningCount != null ? var.agentProfileResourcePredictionsManual.sunday.provisioningCount : var.maximumConcurrency
      "${var.agentProfileResourcePredictionsManual.sunday.endTime}"   = 0
    },
    # Monday
    length(keys(var.agentProfileResourcePredictionsManual.monday)) == 0 || var.agentProfileResourcePredictionsManual.monday.startTime == null ? {} : {
      "${var.agentProfileResourcePredictionsManual.monday.startTime}" = var.agentProfileResourcePredictionsManual.monday.provisioningCount != null ? var.agentProfileResourcePredictionsManual.monday.provisioningCount : var.maximumConcurrency
      "${var.agentProfileResourcePredictionsManual.monday.endTime}"   = 0
    },
    # Tuesday
    length(keys(var.agentProfileResourcePredictionsManual.tuesday)) == 0 || var.agentProfileResourcePredictionsManual.tuesday.startTime == null ? {} : {
      "${var.agentProfileResourcePredictionsManual.tuesday.startTime}" = var.agentProfileResourcePredictionsManual.tuesday.provisioningCount != null ? var.agentProfileResourcePredictionsManual.tuesday.provisioningCount : var.maximumConcurrency
      "${var.agentProfileResourcePredictionsManual.tuesday.endTime}"   = 0
    },
    # Wednesday
    length(keys(var.agentProfileResourcePredictionsManual.wednesday)) == 0 || var.agentProfileResourcePredictionsManual.wednesday.startTime == null ? {} : {
      "${var.agentProfileResourcePredictionsManual.wednesday.startTime}" = var.agentProfileResourcePredictionsManual.wednesday.provisioningCount != null ? var.agentProfileResourcePredictionsManual.wednesday.provisioningCount : var.maximumConcurrency
      "${var.agentProfileResourcePredictionsManual.wednesday.endTime}"   = 0
    },
    # Thursday
    length(keys(var.agentProfileResourcePredictionsManual.thursday)) == 0 || var.agentProfileResourcePredictionsManual.thursday.startTime == null ? {} : {
      "${var.agentProfileResourcePredictionsManual.thursday.startTime}" = var.agentProfileResourcePredictionsManual.thursday.provisioningCount != null ? var.agentProfileResourcePredictionsManual.thursday.provisioningCount : var.maximumConcurrency
      "${var.agentProfileResourcePredictionsManual.thursday.endTime}"   = 0
    },
    # Friday
    length(keys(var.agentProfileResourcePredictionsManual.friday)) == 0 || var.agentProfileResourcePredictionsManual.friday.startTime == null ? {} : {
      "${var.agentProfileResourcePredictionsManual.friday.startTime}" = var.agentProfileResourcePredictionsManual.friday.provisioningCount != null ? var.agentProfileResourcePredictionsManual.friday.provisioningCount : var.maximumConcurrency
      "${var.agentProfileResourcePredictionsManual.friday.endTime}"   = 0
    },
    # Saturday
    length(keys(var.agentProfileResourcePredictionsManual.saturday)) == 0 || var.agentProfileResourcePredictionsManual.saturday.startTime == null ? {} : {
      "${var.agentProfileResourcePredictionsManual.saturday.startTime}" = var.agentProfileResourcePredictionsManual.saturday.provisioningCount != null ? var.agentProfileResourcePredictionsManual.saturday.provisioningCount : var.maximumConcurrency
      "${var.agentProfileResourcePredictionsManual.saturday.endTime}"   = 0
    }
  ]
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
  organizationProfile = {
    organizations = [for org in var.organizationProfile.organizations : {
      url         = "https://dev.azure.com/${org.name}"
      projects    = org.projects
      parallelism = org.parallelism != null ? org.parallelism : var.maximumConcurrency
    }]
    permissionProfile = {
      kind   = var.organizationProfile.permission_profile.kind # "CreatorOnly", "Inherit", "SpecificAccounts"
      users  = var.organizationProfile.permission_profile.kind == "SpecificAccounts" ? var.organizationProfile.permission_profile.users : null
      groups = var.organizationProfile.permission_profile.kind == "SpecificAccounts" ? var.organizationProfile.permission_profile.groups : null
    }
  }
  resourcePredictionsProfile = (
    var.agentProfileResourcePredictionProfile == "None" ? null :
    var.agentProfileResourcePredictionProfile == "Automatic" ? var.agentProfileResourcePredictionProfileAutomatic :
    var.agentProfileResourcePredictionProfile == "Manual" ? var.agentProfileResourcePredictionProfileManual : null
  )
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  subscription_id                    = coalesce(var.subscription_id, data.azurerm_client_config.this.subscription_id)
}