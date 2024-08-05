output "name" {
  description = "The name of the Managed DevOps Pool."
  value       = azapi_resource.mdp.name
}

output "resource_id" {
  description = "The resource if of the Managed DevOps Pool."
  value       = azapi_resource.mdp.id
}

output "resource" {
  description = "This is the full output for the Managed DevOps Pool."
  value       = azapi_resource.mdp
}
