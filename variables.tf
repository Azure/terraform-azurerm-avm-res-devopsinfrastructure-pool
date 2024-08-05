variable "dev_center_project_resource_id" {
  type        = string
  description = "(Required) The resource ID of the Dev Center project."
  nullable = false
}

variable "fabric_profile_images" {
  type = list(object({
    resource_id         = optional(string)
    well_known_image_name = optional(string)
    buffer             = optional(string, "*")
    aliases            = optional(list(string))
  }))
  default = [{
    well_known_image_name = "ubuntu-22.04"
  }]

  description = "The list of images to use for the fabric profile. Defaults to the Ubuntu 22.04 agent image."
}

variable "fabric_profile_os_disk_storage_account_type" {
  type        = string
  description = "The storage account type for the OS disk."
  default = "Premium"
  validation {
    condition     = can(index(["Standard", "Premium", "StandardSSD"], var.fabric_profile_os_disk_storage_account_type))
    error_message = "The osDiskStorageAccountType must be one of: 'Standard', 'Premium', 'StandardSSD'."
  }
}

variable "fabric_profile_sku_name" {
  type        = string
  default = "Standard_D2ads_v5"
  description = "The SKU name of the fabric profile. Defaults to Standard_D2ads_v5."
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "maximum_concurrency" {
  type        = number
  description = "The maximum number of agents that can run concurrently."
  default     = 5

  validation {
    condition     = var.maximum_concurrency >= 1 && var.maximum_concurrency <= 10000
    error_message = "The maximumConcurrency must be between 1 and 10000. Defaults to 10000"
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

variable "organization_profile" {
  type = object({
    kind          = optional(string, "AzureDevOps")
    organizations = list(object({
      name        = string
      projects    = optional(list(string), []) # List of all Projects names this agent should run on, if empty, it will run on all projects.
      parallelism = optional(number)           # If multiple organizations are specified, this value needs to be set, otherwise it will use the var.maximumConcurrency value.
    }))
    permission_profile = optional(object({
      kind   = optional(string, "CreatorOnly")
      users  = optional(list(string), null)
      groups = optional(list(string), null)
    }), {
      kind = "CreatorOnly"
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

variable "agent_profile_grace_period_time_span" {
  type        = string
  default     = null
  description = "How long should the stateful machines be kept around. Maximum value is 7 days and the format must be in `d:hh:mm:ss`."
}

variable "agent_profile_kind" {
  type        = string
  default     = "Stateless"
  description = "The kind of agent profile."

  validation {
    condition     = can(index(["Stateless", "Stateful"], var.agent_profile_kind))
    error_message = "The agent_profile_kind must be one of: 'Stateless', 'Stateful'."
  }
}

variable "agent_profile_max_agent_lifetime" {
  type        = string
  default     = null
  description = "The maximum lifetime of the agent. Maximum value is 7 days and the format must be in `d:hh:mm:ss`."
}

variable "agent_profile_resource_prediction_profile" {
  type        = string
  default     = "None"
  description = "The resource prediction profile for the agent."

  validation {
    condition     = can(index(["None", "Manual", "Automatic"], var.agent_profile_resource_prediction_profile))
    error_message = "The agent_profile_resource_prediction_profile must be one of: 'None', 'Manual', 'Automatic'."
  }
}

variable "agent_profile_resource_prediction_profile_automatic" {
  type = object({
    kind                 = string
    prediction_preference = string
  })
  default = {
    kind                 = "Automatic"
    prediction_preference = "Balanced"
  }
  description = "The automatic resource prediction profile for the agent."

  validation {
    condition     = var.agent_profile_resource_prediction_profile == "Automatic" || var.agent_profile_resource_prediction_profile_automatic != null
    error_message = "The input for agent_profile_resource_prediction_profile_automatic must be set when agent_profile_resource_prediction_profile is 'Automatic'."
  }
  validation {
    condition     = can(index(["Balanced", "MostCostEffective", "MoreCostEffective", "MorePerformance", "BestPerformance"], var.agent_profile_resource_prediction_profile_automatic.prediction_preference))
    error_message = "The prediction_preference must be one of: 'Balanced', 'MostCostEffective', 'MoreCostEffective', 'MorePerformance', 'BestPerformance'."
  }
}

variable "agent_profile_resource_prediction_profile_manual" {
  type = object({
    kind = string
  })
  default = {
    kind = "Manual"
  }
  description = "The manual resource prediction profile for the agent."
}

variable "agent_profile_resource_predictions_manual" {
  type = object({
    time_zone = optional(string)
    days_data = optional(list(map(number)))
  })
  default     = {}
  description = <<DESCRIPTION
An object representing manual resource predictions for agent profiles, including time zone and optional daily schedules.

- `time_zone` - (Optional) The time zone for the agent profile. E.g. "Eastern Standard Time".
- `days_data` - (Optional) A list representing the manual schedules

The `days_data` list should contain one or seven maps. Supply one to apply the same schedule each day. Supply seven for a different schedule each day.

For example, to set the schedule for every day to scale to one agent at 8:00 AM and scale down to zero agents at 5:00 PM, you would use the following configuration:

```hcl
agent_profile_resource_predictions_manual = {
  time_zone = "Eastern Standard Time"
  days_data = [
    {
      "08:00:00" = 1
      "17:00:00" = 0
    }
  ]
}
```

To set a different schedule for each day, you would use the following configuration:

```hcl
agent_profile_resource_predictions_manual = {
  time_zone = "Eastern Standard Time"
  days_data = [
    # Sunday
    {}, # Empty map to skip Sunday
    # Monday
    {
      "03:00:00" = 2  # Scale to 2 agents at 3:00 AM
      "08:00:00" = 4  # Scale to 4 agents at 8:00 AM
      "17:00:00" = 2  # Scale to 2 agents at 5:00 PM
      "22:00:00" = 0  # Scale to 0 agents at 10:00 PM
    },
    # Tuesday
    {
      "08:00:00" = 2
      "17:00:00" = 0
    },
    # Wednesday
    {
      "08:00:00" = 2
      "17:00:00" = 0
    },
    # Thursday
    {
      "08:00:00" = 2
      "17:00:00" = 0
    },
    # Friday
    {
      "08:00:00" = 2
      "17:00:00" = 0
    },
    # Saturday
    {} # Empty map to skip Saturday
  ]
}
```

DESCRIPTION

  validation {
    condition = var.agent_profile_resource_predictions_manual.days_data == null ? true : contains([1,7], length(var.agent_profile_resource_predictions_manual.days_data))
    error_message = "The days_data list must contain one or seven maps."
  }
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

variable "fabric_profile_data_disks" {
  type = list(object({
    caching             = optional(string, "ReadWrite")
    disk_size_gigabytes = optional(number, 100)
    drive_letter         = optional(string, null)
    storage_account_type  = optional(string, "Premium_ZRS")
  }))
  default     = []
  description = <<DESCRIPTION
A list of objects representing the configuration for fabric profile data disks.

- `caching` - (Optional) The caching setting for the data disk. Valid values are `None`, `ReadOnly`, and `ReadWrite`. Defaults to `ReadWrite`.
- `disk_size_gigabytes` - (Optional) The size of the data disk in GiB. Defaults to 100GB.
- `drive_letter` - (Optional) The drive letter for the data disk, If you have any Windows agent images in your pool, choose a drive letter for your disk. If you don't specify a drive letter, `F` is used for VM sizes with a temporary disk; otherwise `E` is used. The drive letter must be a single letter except A, C, D, or E. If you are using a VM size without a temporary disk and want `E` as your drive letter, leave Drive Letter empty to get the default value of `E`.
- `storage_account_type` - (Optional) The storage account type for the data disk. Defaults to "Premium_ZRS".

Valid values for `storage_account_type` are:
- `Premium_LRS`
- `Premium_ZRS`
- `StandardSSD_LRS`
- `Standard_LRS`
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for disk in var.fabric_profile_data_disks : can(index(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "Standard_LRS"], disk.storage_account_type))])
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

variable "subnet_id" {
  type        = string
  default     = null
  description = "The subnet id on which to put all machines created in the pool"
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "The subscription ID to use for the resource."
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
