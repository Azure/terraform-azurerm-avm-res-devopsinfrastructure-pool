<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource.mdp](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_devCenterProjectResourceId"></a> [devCenterProjectResourceId](#input\_devCenterProjectResourceId)

Description: The resource ID of the Dev Center project.

Type: `string`

### <a name="input_fabricProfileImages"></a> [fabricProfileImages](#input\_fabricProfileImages)

Description: The list of images to use for the fabric profile.

Type:

```hcl
list(object({
    resourceId         = optional(string)
    wellKnownImageName = optional(string)
    buffer             = string
    aliases            = list(string)
  }))
```

### <a name="input_fabricProfileOsDiskStorageAccountType"></a> [fabricProfileOsDiskStorageAccountType](#input\_fabricProfileOsDiskStorageAccountType)

Description: The storage account type for the OS disk.

Type: `string`

### <a name="input_fabricProfileSkuName"></a> [fabricProfileSkuName](#input\_fabricProfileSkuName)

Description: The SKU name of the fabric profile.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_maximumConcurrency"></a> [maximumConcurrency](#input\_maximumConcurrency)

Description: The maximum number of agents that can run concurrently.

Type: `number`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the pool. It needs to be globally unique for each Azure DevOps Organization.

Type: `string`

### <a name="input_organizationProfile"></a> [organizationProfile](#input\_organizationProfile)

Description: An object representing the configuration for an organization profile, including organizations and permission profiles.

- `organizations` - (Required) A list of objects representing the organizations.
  - `name` - (Required) The name of the organization, without the `https://dev.azure.com/` prefix.
  - `projects` - (Optional) A list of project names this agent should run on. If empty, it will run on all projects. Defaults to `[]`.
  - `parallelism` - (Optional) The parallelism value. If multiple organizations are specified, this value needs to be set and cannot exceed the total value of `var.maximumConcurrency`; otherwise, it will use the `var.maximumConcurrency` value as default or the value you define for single Organization.
- `permission_profile` - (Required) An object representing the permission profile.
  - `kind` - (Required) The kind of permission profile, possible values are `CreatorOnly`, `Inherit`, and `SpecificAccounts`, if `SpecificAccounts` is chosen, you must provide a list of users and/or groups.
  - `users` - (Optional) A list of users for the permission profile, supported value is the `ObjectID` or `UserPrincipalName`. Defaults to `null`.
  - `groups` - (Optional) A list of groups for the permission profile, supported value is the `ObjectID` of the group. Defaults to `null`.

Type:

```hcl
object({
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
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_agentProfileGracePeriodTimeSpan"></a> [agentProfileGracePeriodTimeSpan](#input\_agentProfileGracePeriodTimeSpan)

Description: How long should the stateful machines be kept around. Maximum value is 7 days and the format must be in `d:hh:mm:ss`.

Type: `string`

Default: `null`

### <a name="input_agentProfileKind"></a> [agentProfileKind](#input\_agentProfileKind)

Description: The kind of agent profile.

Type: `string`

Default: `"Stateless"`

### <a name="input_agentProfileMaxAgentLifetime"></a> [agentProfileMaxAgentLifetime](#input\_agentProfileMaxAgentLifetime)

Description: The maximum lifetime of the agent. Maximum value is 7 days and the format must be in `d:hh:mm:ss`.

Type: `string`

Default: `null`

### <a name="input_agentProfileResourcePredictionProfile"></a> [agentProfileResourcePredictionProfile](#input\_agentProfileResourcePredictionProfile)

Description: The resource prediction profile for the agent.

Type: `string`

Default: `"None"`

### <a name="input_agentProfileResourcePredictionProfileAutomatic"></a> [agentProfileResourcePredictionProfileAutomatic](#input\_agentProfileResourcePredictionProfileAutomatic)

Description: The automatic resource prediction profile for the agent.

Type:

```hcl
object({
    kind                 = string
    predictionPreference = string
  })
```

Default:

```json
{
  "kind": "Automatic",
  "predictionPreference": "Balanced"
}
```

### <a name="input_agentProfileResourcePredictionProfileManual"></a> [agentProfileResourcePredictionProfileManual](#input\_agentProfileResourcePredictionProfileManual)

Description: The manual resource prediction profile for the agent.

Type:

```hcl
object({
    kind = string
  })
```

Default:

```json
{
  "kind": "Manual"
}
```

### <a name="input_agentProfileResourcePredictionsManual"></a> [agentProfileResourcePredictionsManual](#input\_agentProfileResourcePredictionsManual)

Description: An object representing manual resource predictions for agent profiles, including time zone and optional daily schedules.

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

Type:

```hcl
object({
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
```

Default: `{}`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_fabricProfileDataDisks"></a> [fabricProfileDataDisks](#input\_fabricProfileDataDisks)

Description: A list of objects representing the configuration for fabric profile data disks.

- `caching` - (Optional) The caching setting for the data disk. Valid values are `None`, `ReadOnly`, and `ReadWrite`. Defaults to `ReadWrite`.
- `diskSizeGiB` - (Required) The size of the data disk in GiB.
- `driveLetter` - (Optional) The drive letter for the data disk, If you have any Windows agent images in your pool, choose a drive letter for your disk. If you don't specify a drive letter, `F` is used for VM sizes with a temporary disk; otherwise `E` is used. The drive letter must be a single letter except A, C, D, or E. If you are using a VM size without a temporary disk and want `E` as your drive letter, leave Drive Letter empty to get the default value of `E`.
- `storageAccountType` - (Optional) The storage account type for the data disk. Defaults to "Standard\_LRS".

Valid values for `storageAccountType` are:
- `Premium_LRS`
- `Premium_ZRS`
- `StandardSSD_LRS`
- `Standard_LRS`

Type:

```hcl
list(object({
    caching            = optional(string, "ReadWrite")
    diskSizeGiB        = number
    driveLetter        = optional(string, null)
    storageAccountType = optional(string, "Standard_LRS")
  }))
```

Default: `[]`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_subnetId"></a> [subnetId](#input\_subnetId)

Description: The subnet id on which to put all machines created in the pool

Type: `string`

Default: `null`

### <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id)

Description: The subscription ID to use for the resource.

Type: `string`

Default: `""`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->