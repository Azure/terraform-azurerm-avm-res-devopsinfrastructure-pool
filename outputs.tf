output "name" {
  description = "The name of the Managed DevOps Pool."
  value       = azapi_resource.managed_devops_pool.name
}

output "resource_id" {
  description = "The resource if of the Managed DevOps Pool."
  value       = azapi_resource.managed_devops_pool.id
}

output "resource" {
  description = "This is the full output for the Managed DevOps Pool."
  value       = azapi_resource.managed_devops_pool
}
