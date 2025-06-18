output "managed_devops_pool_id" {
  value = module.managed_devops_pool.resource_id
}

output "managed_devops_pool_name" {
  value = module.managed_devops_pool.name
}

output "virtual_network_id" {
  value = module.virtual_network.resource_id
}

output "virtual_network_subnets" {
  value = module.virtual_network.subnets
}
