variable "devCenterProjectResourceId" {
  type        = string
  description = "The resource ID of the Dev Center project."
}

variable "fabricProfileImages" {
  type = list(object({
    resourceId         = optional(string)
    wellKnownImageName = optional(string)
    buffer             = string
    aliases            = list(string)
  }))
  description = "The list of images to use for the fabric profile."
}

variable "fabricProfileOsDiskStorageAccountType" {
  type        = string
  description = "The storage account type for the OS disk."

  validation {
    condition     = can(index(["Standard", "Premium", "StandardSSD"], var.fabricProfileOsDiskStorageAccountType))
    error_message = "The osDiskStorageAccountType must be one of: 'Standard', 'Premium', 'StandardSSD'."
  }
}

variable "fabricProfileSkuName" {
  type        = string
  description = "The SKU name of the fabric profile."
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "maximumConcurrency" {
  type        = number
  description = "The maximum number of agents that can run concurrently."

  validation {
    condition     = var.maximumConcurrency >= 1 && var.maximumConcurrency <= 10000
    error_message = "The maximumConcurrency must be between 1 and 10000."
  }
}

variable "name" {
  type        = string
  description = "Name of the pool. It needs to be globally unique for each Azure DevOps Organization."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-.]{3,44}$", var.name))
    error_message = "The name must be between 3 and 44 characters long, start with an alphanumeric character, and can only contain alphanumeric characters, hyphens, and dots."
  }
}

variable "organizationProfile" {
  type = object({
    organizations = list(object({
      name        = string
      projects    = optional(list(string), []) # List of all Projects names this agent should run on, if empty, it will run on all projects.
      parallelism = optional(number)           # If multiple organizations are specified, this value needs to be set, otherwise it will use the var.maximumConcurrency value.
    }))
    permission_profile = object({
      kind   = string
      users  = optional(list(string), null)
      groups = optional(list(string), null)
    })
  })
  description = <<DESCRIPTION
An object representing the configuration for an organization profile, including organizations and permission profiles.

- `organizations` - (Required) A list of objects representing the organizations.
  - `name` - (Required) The name of the organization, without the `https://dev.azure.com/` prefix.
  - `projects` - (Optional) A list of project names this agent should run on. If empty, it will run on all projects. Defaults to `[]`.
  - `parallelism` - (Optional) The parallelism value. If multiple organizations are specified, this value needs to be set and cannot exceed the total value of `var.maximumConcurrency`; otherwise, it will use the `var.maximumConcurrency` value as default or the value you define for single Organization.
- `permission_profile` - (Required) An object representing the permission profile.
  - `kind` - (Required) The kind of permission profile, possible values are `CreatorOnly`, `Inherit`, and `SpecificAccounts`, if `SpecificAccounts` is chosen, you must provide a list of users and/or groups.
  - `users` - (Optional) A list of users for the permission profile, supported value is the `ObjectID` or `UserPrincipalName`. Defaults to `null`.
  - `groups` - (Optional) A list of groups for the permission profile, supported value is the `ObjectID` of the group. Defaults to `null`.
DESCRIPTION
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "agentProfileGracePeriodTimeSpan" {
  type        = string
  default     = null
  description = "How long should the stateful machines be kept around. Maximum value is 7 days and the format must be in `d:hh:mm:ss`."
}

variable "agentProfileKind" {
  type        = string
  default     = "Stateless"
  description = "The kind of agent profile."

  validation {
    condition     = can(index(["Stateless", "Stateful"], var.agentProfileKind))
    error_message = "The agentProfileKind must be one of: 'Stateless', 'Stateful'."
  }
}

variable "agentProfileMaxAgentLifetime" {
  type        = string
  default     = null
  description = "The maximum lifetime of the agent. Maximum value is 7 days and the format must be in `d:hh:mm:ss`."
}

variable "agentProfileResourcePredictionProfile" {
  type        = string
  default     = "None"
  description = "The resource prediction profile for the agent."

  validation {
    condition     = can(index(["None", "Manual", "Automatic"], var.agentProfileResourcePredictionProfile))
    error_message = "The agentProfileResourcePredictionProfile must be one of: 'None', 'Manual', 'Automatic'."
  }
}

variable "agentProfileResourcePredictionProfileAutomatic" {
  type = object({
    kind                 = string
    predictionPreference = string
  })
  default = {
    kind                 = "Automatic"
    predictionPreference = "Balanced"
  }
  description = "The automatic resource prediction profile for the agent."

  validation {
    condition     = var.agentProfileResourcePredictionProfile == "Automatic" || var.agentProfileResourcePredictionProfileAutomatic != null
    error_message = "The input for agentProfileResourcePredictionProfileAutomatic must be set when agentProfileResourcePredictionProfile is 'Automatic'."
  }
  validation {
    condition     = can(index(["Balanced", "MostCostEffective", "MoreCostEffective", "MorePerformance", "BestPerformance"], var.agentProfileResourcePredictionProfileAutomatic.predictionPreference))
    error_message = "The predictionPreference must be one of: 'Balanced', 'MostCostEffective', 'MoreCostEffective', 'MorePerformance', 'BestPerformance'."
  }
}

variable "agentProfileResourcePredictionProfileManual" {
  type = object({
    kind = string
  })
  default = {
    kind = "Manual"
  }
  description = "The manual resource prediction profile for the agent."
}

variable "agentProfileResourcePredictionsManual" {
  type = object({
    timeZone = optional(string)
    sunday = optional(object({
      startTime         = optional(string)
      endTime           = optional(string)
      provisioningCount = optional(number)
    }), {})
    monday = optional(object({
      startTime         = optional(string)
      endTime           = optional(string)
      provisioningCount = optional(number)
    }), {})
    tuesday = optional(object({
      startTime         = optional(string)
      endTime           = optional(string)
      provisioningCount = optional(number)
    }), {})
    wednesday = optional(object({
      startTime         = optional(string)
      endTime           = optional(string)
      provisioningCount = optional(number)
    }), {})
    thursday = optional(object({
      startTime         = optional(string)
      endTime           = optional(string)
      provisioningCount = optional(number)
    }), {})
    friday = optional(object({
      startTime         = optional(string)
      endTime           = optional(string)
      provisioningCount = optional(number)
    }), {})
    saturday = optional(object({
      startTime         = optional(string)
      endTime           = optional(string)
      provisioningCount = optional(number)
    }), {})
  })
  default     = {}
  description = <<DESCRIPTION
An object representing manual resource predictions for agent profiles, including time zone and optional daily schedules.

- `timeZone` - (Required) The time zone for the agent profile.
- `sunday` - (Optional) An object representing the schedule for Sunday. Defaults to `{}` which means standby agents will be set to 0 for Sunday.
  - `startTime` - (Required) The start time for the schedule.
  - `endTime` - (Required) The end time for the schedule.
  - `provisioningCount` - (Required) The number of provisions for the schedule.
- `monday` - (Optional) An object representing the schedule for Monday. Defaults to `{}` which means standby agents will be set to 0 for Monday.
  - `startTime` - (Required) The start time for the schedule
  - `endTime` - (Required) The end time for the schedule.
  - `provisioningCount` - (Required) The number of provisions for the schedule, if not set, it will use the `var.maximumConcurrency` value.
- `tuesday` - (Optional) An object representing the schedule for Tuesday. Defaults to `{}` which means standby agents will be set to 0 for Tuesday.
  - `startTime` - (Required) The start time for the schedule.
  - `endTime` - (Required) The end time for the schedule.
  - `provisioningCount` - (Required) The number of provisions for the schedule.
- `wednesday` - (Optional) An object representing the schedule for Wednesday. Defaults to `{}` which means standby agents will be set to 0 for Wednesday.
  - `startTime` - (Required) The start time for the schedule.
  - `endTime` - (Required) The end time for the schedule.
  - `provisioningCount` - (Required) The number of provisions for the schedule.
- `thursday` - (Optional) An object representing the schedule for Thursday. Defaults to `{}` which means standby agents will be set to 0 for Thursday.
  - `startTime` - (Required) The start time for the schedule.
  - `endTime` - (Required) The end time for the schedule.
  - `provisioningCount` - (Required) The number of provisions for the schedule.
- `friday` - (Optional) An object representing the schedule for Friday. Defaults to `{}` which means standby agents will be set to 0 for Friday.
  - `startTime` - (Required) The start time for the schedule.
  - `endTime` - (Required) The end time for the schedule.
  - `provisioningCount` - (Required) The number of provisions for the schedule.
- `saturday` - (Optional) An object representing the schedule for Saturday. Defaults to `{}` which means standby agents will be set to 0 for Saturday.
  - `startTime` - (Required) The start time for the schedule.
  - `endTime` - (Required) The end time for the schedule.
  - `provisioningCount` - (Required) The number of provisions for the schedule.
DESCRIPTION
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION  
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "fabricProfileDataDisks" {
  type = list(object({
    caching            = optional(string, "ReadWrite")
    diskSizeGiB        = number
    driveLetter        = optional(string, null)
    storageAccountType = optional(string, "Standard_LRS")
  }))
  default     = []
  description = <<DESCRIPTION
A list of objects representing the configuration for fabric profile data disks.

- `caching` - (Optional) The caching setting for the data disk. Valid values are `None`, `ReadOnly`, and `ReadWrite`. Defaults to `ReadWrite`.
- `diskSizeGiB` - (Required) The size of the data disk in GiB.
- `driveLetter` - (Optional) The drive letter for the data disk, If you have any Windows agent images in your pool, choose a drive letter for your disk. If you don't specify a drive letter, `F` is used for VM sizes with a temporary disk; otherwise `E` is used. The drive letter must be a single letter except A, C, D, or E. If you are using a VM size without a temporary disk and want `E` as your drive letter, leave Drive Letter empty to get the default value of `E`.
- `storageAccountType` - (Optional) The storage account type for the data disk. Defaults to "Standard_LRS".

Valid values for `storageAccountType` are:
- `Premium_LRS`
- `Premium_ZRS`
- `StandardSSD_LRS`
- `Standard_LRS`
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for disk in var.fabricProfileDataDisks : can(index(["Standard", "Premium", "StandardSSD"], disk.storageAccountType))])
    error_message = "The storageAccountType must be one of: 'Premium_LRS', 'Premium_ZRS', 'StandardSSD_LRS', or `Standard_LRS`."
  }
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "subnetId" {
  type        = string
  default     = null
  description = "The subnet id on which to put all machines created in the pool"
}

variable "subscription_id" {
  type        = string
  default     = ""
  description = "The subscription ID to use for the resource."
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
