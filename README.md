<!-- BEGIN_TF_DOCS -->
# Azure Verified Module for Managed DevOps Pools

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

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.13, < 3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.116.0, < 5.0.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6.3)

## Resources

The following resources are used by this module:

- [azapi_resource.managed_devops_pool](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_dev_center_project_resource_id"></a> [dev\_center\_project\_resource\_id](#input\_dev\_center\_project\_resource\_id)

Description: (Required) The resource ID of the Dev Center project.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the pool. It needs to be globally unique for each Azure DevOps Organization.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_agent_profile_grace_period_time_span"></a> [agent\_profile\_grace\_period\_time\_span](#input\_agent\_profile\_grace\_period\_time\_span)

Description: How long should the stateful machines be kept around. Maximum value is 7 days and the format must be in `d:hh:mm:ss`.

Type: `string`

Default: `null`

### <a name="input_agent_profile_kind"></a> [agent\_profile\_kind](#input\_agent\_profile\_kind)

Description: The kind of agent profile.

Type: `string`

Default: `"Stateless"`

### <a name="input_agent_profile_max_agent_lifetime"></a> [agent\_profile\_max\_agent\_lifetime](#input\_agent\_profile\_max\_agent\_lifetime)

Description: The maximum lifetime of the agent. Maximum value is 7 days and the format must be in `d:hh:mm:ss`.

Type: `string`

Default: `null`

### <a name="input_agent_profile_resource_prediction_profile"></a> [agent\_profile\_resource\_prediction\_profile](#input\_agent\_profile\_resource\_prediction\_profile)

Description: The resource prediction profile for the agent, a.k.a `Stand by agent mode`, supported values are 'Off', 'Manual', 'Automatic', defaults to 'Off'.

Type: `string`

Default: `"Off"`

### <a name="input_agent_profile_resource_prediction_profile_automatic"></a> [agent\_profile\_resource\_prediction\_profile\_automatic](#input\_agent\_profile\_resource\_prediction\_profile\_automatic)

Description: The automatic resource prediction profile for the agent.

The object can have the following attributes:
- `kind` - (Required) The kind of prediction profile. Default is "Automatic".
- `prediction_preference` - (Required) The preference for resource prediction. Supported values are `Balanced`, `MostCostEffective`, `MoreCostEffective`, `MorePerformance`, and `BestPerformance`.

Type:

```hcl
object({
    kind                  = optional(string, "Automatic")
    prediction_preference = optional(string, "Balanced")
  })
```

Default:

```json
{
  "kind": "Automatic",
  "prediction_preference": "Balanced"
}
```

### <a name="input_agent_profile_resource_prediction_profile_manual"></a> [agent\_profile\_resource\_prediction\_profile\_manual](#input\_agent\_profile\_resource\_prediction\_profile\_manual)

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

### <a name="input_agent_profile_resource_predictions_manual"></a> [agent\_profile\_resource\_predictions\_manual](#input\_agent\_profile\_resource\_predictions\_manual)

Description: An object representing manual resource predictions for agent profiles, including time zone and optional daily schedules.

- `time_zone` - (Optional) The time zone for the agent profile. E.g. "Eastern Standard Time". Defaults to `UTC`. To see valid values for this run this command in PowerShell: `[System.TimeZoneInfo]::GetSystemTimeZones() | Select Id, BaseUtcOffSet`
- `days_data` - (Optional) A list representing the manual schedules. Defaults to a single standby agent constantly running.

The `days_data` list should contain one or seven maps. Supply one to apply the same schedule each day. Supply seven for a different schedule each day.

Examples:

- To set always having 1 agent available, you would use the following configuration:

  ```hcl
  agent_profile_resource_predictions_manual = {
    days_data = [
      {
        "00:00:00" = 1
      }
    ]
  }
```

- To set the schedule for every day to scale to one agent at 8:00 AM and scale down to zero agents at 5:00 PM, you would use the following configuration:

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

- To set a different schedule for each day, you would use the following configuration:

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

Type:

```hcl
object({
    time_zone = optional(string, "UTC")
    days_data = optional(list(map(number)))
  })
```

Default:

```json
{
  "days_data": [
    {
      "00:00:00": 1
    }
  ]
}
```

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

### <a name="input_fabric_profile_data_disks"></a> [fabric\_profile\_data\_disks](#input\_fabric\_profile\_data\_disks)

Description: A list of objects representing the configuration for fabric profile data disks.

- `caching` - (Optional) The caching setting for the data disk. Valid values are `None`, `ReadOnly`, and `ReadWrite`. Defaults to `ReadWrite`.
- `disk_size_gigabytes` - (Optional) The size of the data disk in GiB. Defaults to 100GB.
- `drive_letter` - (Optional) The drive letter for the data disk, If you have any Windows agent images in your pool, choose a drive letter for your disk. If you don't specify a drive letter, `F` is used for VM sizes with a temporary disk; otherwise `E` is used. The drive letter must be a single letter except A, C, D, or E. If you are using a VM size without a temporary disk and want `E` as your drive letter, leave Drive Letter empty to get the default value of `E`.
- `storage_account_type` - (Optional) The storage account type for the data disk. Defaults to "Premium\_ZRS".

Valid values for `storage_account_type` are:
- `Premium_LRS`
- `Premium_ZRS`
- `StandardSSD_LRS`
- `Standard_LRS`

Type:

```hcl
list(object({
    caching              = optional(string, "ReadWrite")
    disk_size_gigabytes  = optional(number, 100)
    drive_letter         = optional(string, null)
    storage_account_type = optional(string, "Premium_ZRS")
  }))
```

Default: `[]`

### <a name="input_fabric_profile_images"></a> [fabric\_profile\_images](#input\_fabric\_profile\_images)

Description: The list of images to use for the fabric profile.

Each object in the list can have the following attributes:
- `resource_id` - (Optional) The resource ID of the image, this can either be resource ID of a Standard Azure VM Image or a Image that is hosted within Azure Image Gallery.
- `well_known_image_name` - (Optional) The well-known name of the image, thid is used to reference the well-known images that are available on Microsoft Hosted Agents, supported images are `ubuntu-22.04/latest`, `ubuntu-20.04/latest`, `windows-2022/latest`, and `windows-2019/latest`.
- `buffer` - (Optional) The buffer associated with the image.
- `aliases` - (Required) A list of aliases for the image.

Type:

```hcl
list(object({
    resource_id           = optional(string)
    well_known_image_name = optional(string)
    buffer                = optional(string, "*")
    aliases               = optional(list(string))
  }))
```

Default:

```json
[
  {
    "aliases": [
      "ubuntu-22.04/latest"
    ],
    "well_known_image_name": "ubuntu-22.04/latest"
  }
]
```

### <a name="input_fabric_profile_os_disk_storage_account_type"></a> [fabric\_profile\_os\_disk\_storage\_account\_type](#input\_fabric\_profile\_os\_disk\_storage\_account\_type)

Description: The storage account type for the OS disk, possible values are 'Standard', 'Premium' and 'StandardSSD', defaults to 'Premium'.

Type: `string`

Default: `"Premium"`

### <a name="input_fabric_profile_os_profile_logon_type"></a> [fabric\_profile\_os\_profile\_logon\_type](#input\_fabric\_profile\_os\_profile\_logon\_type)

Description: The logon type for the OS profile, possible values are 'Interactive' and 'Service', defaults to 'Service'.

Type: `string`

Default: `"Service"`

### <a name="input_fabric_profile_sku_name"></a> [fabric\_profile\_sku\_name](#input\_fabric\_profile\_sku\_name)

Description: The SKU name of the fabric profile, make sure you have enough quota for the SKU, the CPUs are multiplied by the `maximum_concurrency` value, make sure you request enough quota, defaults to 'Standard\_D2ads\_v5' which has 2 vCPU Cores. so if maximum\_concurrency is 2, you will need quota for 4 vCPU Cores and so on.

Type: `string`

Default: `"Standard_D2ads_v5"`

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

### <a name="input_maximum_concurrency"></a> [maximum\_concurrency](#input\_maximum\_concurrency)

Description: The maximum number of agents that can run concurrently, must be between 1 and 10000, defaults to 1.

Type: `number`

Default: `1`

### <a name="input_organization_profile"></a> [organization\_profile](#input\_organization\_profile)

Description: An object representing the configuration for an organization profile, including organizations and permission profiles.

This is for advanced use cases where you need to specify permissions and multiple organization.

If not suppled, then `version_control_system_organization_name` and optionally `version_control_system_project_names` must be supplied.

- `organizations` - (Required) A list of objects representing the organizations.
  - `name` - (Required) The name of the organization, without the `https://dev.azure.com/` prefix.
  - `projects` - (Optional) A list of project names this agent should run on. If empty, it will run on all projects. Defaults to `[]`.
  - `parallelism` - (Optional) The parallelism value. If multiple organizations are specified, this value needs to be set and cannot exceed the total value of `maximum_concurrency`; otherwise, it will use the `maximum_concurrency` value as default or the value you define for single Organization.
- `permission_profile` - (Required) An object representing the permission profile.
  - `kind` - (Required) The kind of permission profile, possible values are `CreatorOnly`, `Inherit`, and `SpecificAccounts`, if `SpecificAccounts` is chosen, you must provide a list of users and/or groups.
  - `users` - (Optional) A list of users for the permission profile, supported value is the `ObjectID` or `UserPrincipalName`. Defaults to `null`.
  - `groups` - (Optional) A list of groups for the permission profile, supported value is the `ObjectID` of the group. Defaults to `null`.

Type:

```hcl
object({
    kind = optional(string, "AzureDevOps")
    organizations = list(object({
      name        = string
      projects    = optional(list(string), []) # List of all Projects names this agent should run on, if empty, it will run on all projects.
      parallelism = optional(number)           # If multiple organizations are specified, this value needs to be set, otherwise it will use the maximum_concurrency value.
    }))
    permission_profile = optional(object({
      kind   = optional(string, "CreatorOnly")
      users  = optional(list(string), null)
      groups = optional(list(string), null)
      }), {
      kind = "CreatorOnly"
    })
  })
```

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

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
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The virtual network subnet resource id to use for private networking.

Type: `string`

Default: `null`

### <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id)

Description: The subscription ID to use for the resource. Only required if you want to target a different subscription the the current context.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_version_control_system_organization_name"></a> [version\_control\_system\_organization\_name](#input\_version\_control\_system\_organization\_name)

Description: The name of the version control system organization. This is required if `organization_profile` is not supplied.

Type: `string`

Default: `null`

### <a name="input_version_control_system_project_names"></a> [version\_control\_system\_project\_names](#input\_version\_control\_system\_project\_names)

Description: The name of the version control system project. This is optional if `organization_profile` is not supplied.

Type: `set(string)`

Default: `[]`

### <a name="input_version_control_system_type"></a> [version\_control\_system\_type](#input\_version\_control\_system\_type)

Description: The type of version control system. This is shortcut alternative to `organization_profile.kind`. Possible values are 'azuredevops' or 'github'.

Type: `string`

Default: `"azuredevops"`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Managed DevOps Pool.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the Managed DevOps Pool.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource if of the Managed DevOps Pool.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->