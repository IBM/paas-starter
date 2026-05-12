########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group" {
  value       = module.resource_group.resource_group_name
  description = "The resource group where all resources live."
}

output "cluster_name" {
  value       = module.ocp_base.cluster_name
  description = "The name of the provisioned OCP cluster."
}

output "adminuser" {
  description = "Database admin user name"
  value       = module.database.adminuser
}

output "certificate_base64" {
  description = "Database connection certificate"
  value       = module.database.certificate_base64
  sensitive   = true
}

output "url" {
  description = "Database connection URL"
  value = data.ibm_database_connection.database_connection.postgres[0].composed[0]
}

output "registry_namespace" {
  description = "The namespace for the IBM Cloud Registry"
  value       = ibm_cr_namespace.rg_namespace.name
}
