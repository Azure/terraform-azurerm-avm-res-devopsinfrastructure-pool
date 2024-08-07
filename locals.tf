locals {
  agent_profile = merge(local.agent_profile_base, local.agent_profile_stateful)
  # Workaround to avoid Payload API Spec Validation error, having gracePeriodTimeSpan and maxAgentLifetime in the agentProfile object, even though they had Null value.
  agent_profile_base = {
    kind                       = var.agent_profile_kind
    resourcePredictionsProfile = local.resource_prediction_profile
    resourcePredictions = var.agent_profile_resource_prediction_profile == "Manual" ? {
      timeZone = var.agent_profile_resource_predictions_manual.time_zone
      daysData = var.agent_profile_resource_predictions_manual.days_data
    } : null
  }
  agent_profile_resource_prediction_profile_automatic = {
    kind                 = var.agent_profile_resource_prediction_profile_automatic.kind
    predictionPreference = var.agent_profile_resource_prediction_profile_automatic.prediction_preference
  }
  agent_profile_stateful = var.agent_profile_kind == "Stateful" ? {
    gracePeriodTimeSpan = var.agent_profile_grace_period_time_span
    maxAgentLifetime    = var.agent_profile_max_agent_lifetime
  } : {}
  default_organization_profile = {
    kind = var.version_control_system_type == "azuredevops" ? "AzureDevOps" : "GitHub"
    organizations = [{
      name        = var.version_control_system_organization_name
      projects    = tolist(var.version_control_system_project_names)
      parallelism = var.maximum_concurrency
    }]
    permission_profile = {
      kind   = "CreatorOnly"
      users  = null
      groups = null
    }
  }
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
  organization_profile = {
    organizations = [for org in local.organization_profile_input.organizations : {
      url         = "https://dev.azure.com/${org.name}"
      projects    = org.projects
      parallelism = org.parallelism != null ? org.parallelism : var.maximum_concurrency
    }]
    permission_profile = {
      kind   = local.organization_profile_input.permission_profile.kind # "CreatorOnly", "Inherit", "SpecificAccounts"
      users  = local.organization_profile_input.permission_profile.kind == "SpecificAccounts" ? local.organization_profile_input.permission_profile.users : null
      groups = local.organization_profile_input.permission_profile.kind == "SpecificAccounts" ? local.organization_profile_input.permission_profile.groups : null
    }
  }
  organization_profile_input = var.organization_profile != null ? var.organization_profile : local.default_organization_profile
  resource_prediction_profile = (
    var.agent_profile_resource_prediction_profile == "Off" ? null :
    var.agent_profile_resource_prediction_profile == "Automatic" ? local.agent_profile_resource_prediction_profile_automatic :
    var.agent_profile_resource_prediction_profile == "Manual" ? var.agent_profile_resource_prediction_profile_manual : null
  )
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  subscription_id                    = coalesce(var.subscription_id, data.azurerm_client_config.this.subscription_id)
  version_control_system_type        = var.organization_profile != null ? var.organization_profile.kind : local.default_organization_profile.kind
}
