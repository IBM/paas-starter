########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "A string value to prefix to all resources created by this example."
  default     = "xyz"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable."
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name of the new IBM Cloud OpenShift Cluster"
  default     = null
}

variable "number_worker_nodes" {
  type        = number
  description = "The number of workers to create in the cluster"
  default     = 2
}

variable "ocp_version" {
  type        = string
  description = "Major.minor version of the OCP cluster to provision"
  default     = "4.20"
}

variable "machine_type" {
  type        = string
  description = "Worker node machine type. Use 'ibmcloud ks flavors --zone <zone>' to retrieve the list."
  default     = "bx2.4x16"
}

variable "postgresql_admin_pword" {
  type        = string
  description = "Password for the PostgreSQL admin user"
  sensitive   = true
}
