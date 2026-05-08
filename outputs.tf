########################################################################################################################
# Outputs
########################################################################################################################

#
# Developer tips:
#   - Include all relevant outputs from the modules being called in the example
#
output "resource_group_id" {
  value       = module.cloud_logs.resource_group_id
  description = "The resource group where all resources live."
}

output "cloud_logs_crn" {
  value       = module.cloud_logs.crn
  description = "The id of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_guid" {
  value       = module.cloud_logs.guid
  description = "The guid of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_name" {
  value       = module.cloud_logs.name
  description = "The name of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_ingress_endpoint" {
  value       = module.cloud_logs.ingress_endpoint
  description = "The public ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_ingress_private_endpoint" {
  value       = module.cloud_logs.ingress_private_endpoint
  description = "The private ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "cos_crn" {
  value       = module.cos.cos_instance_id
  description = "The id of the provisioned Cloud Object Storage instance."
}

output "logs_bucket_crn" {
  value       = module.buckets.buckets[local.logs_bucket_name].bucket_crn
  description = "The id of the provisioned Cloud Object Storage bucket for logs."
}

output "logs_bucket_name" {
  value       = local.logs_bucket_name
  description = "The name of the provisioned Cloud Object Storage bucket for logs."
}

output "metrics_bucket_crn" {
  value       = module.buckets.buckets[local.metrics_bucket_name].bucket_crn
  description = "The id of the provisioned Cloud Object Storage bucket for metrics."
}

output "metrics_bucket_name" {
  value       = local.metrics_bucket_name
  description = "The name of the provisioned Cloud Object Storage bucket for metrics."
}

output "cloud_monitoring_crn" {
  value       = module.cloud_monitoring.crn
  description = "The CRN of the provisioned IBM Cloud Monitoring instance."
}

output "cloud_monitoring_name" {
  value       = module.cloud_monitoring.name
  description = "The name of the provisioned IBM Cloud Monitoring instance."
}

output "cloud_monitoring_resource_keys" {
  value       = module.cloud_monitoring.resource_keys
  description = "A list of maps containing resource keys created for the Cloud Monitoring instance."
  sensitive   = true
}

output "cloud_monitoring_access_key" {
  value       = module.cloud_monitoring.access_key
  description = "The Cloud Monitoring access key for agents to use."
  sensitive   = true
}

output "cluster_id" {
  value       = module.ocp_base.cluster_id  
  description = "The id of the provisioned OCP cluster."
}

output "cluster_name" {
  value       = module.ocp_base.cluster_name
  description = "The name of the provisioned OCP cluster."
}

output "id" {
  description = "Postgresql instance id"
  value       = module.database.id
}

output "postgresql_crn" {
  description = "Postgresql CRN"
  value       = module.database.crn
}

output "version" {
  description = "Postgresql instance version"
  value       = module.database.version
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
