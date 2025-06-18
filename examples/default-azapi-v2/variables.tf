variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}
variable "azure_devops_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to Azure DevOps."
  sensitive   = true
}
variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}
variable "azure_devops_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to Azure DevOps."
  sensitive   = true
}
