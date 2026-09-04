output "name" {
  description = "The name of the Managed DevOps Pool."
  value       = azapi_resource.managed_devops_pool.name
}

output "resource" {
  description = "This is the full output for the Managed DevOps Pool."
  value       = azapi_resource.managed_devops_pool
}

output "resource_id" {
  description = "The resource if of the Managed DevOps Pool."
  value       = azapi_resource.managed_devops_pool.id
}

output "static_ip_addresses" {
  description = "The list of static public IP addresses for outgoing connections assigned to the pool. Only populated when `static_ip_address_count` is set."
  value       = try(azapi_resource.managed_devops_pool.output.properties.fabricProfile.networkProfile.ipAddresses, null)
}
