########################################################################################################################
# container registry namespace - since this must be unique across all accounts in a region, we will attempt to create
# it first so if we can try again if it already exists
########################################################################################################################
resource "random_string" "random" {
  length   = 6
  lower    = true
  numeric  = false
  upper    = false
  special  = false
}

resource "ibm_cr_namespace" "rg_namespace" {
  name              = "${var.prefix}-${random_string.random.result}-ns"
  resource_group_id = module.resource_group.resource_group_id
}


########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS instance
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "10.15.2"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  create_cos_bucket = false
}

##############################################################################
# COS buckets
##############################################################################

locals {
  logs_bucket_name    = "${var.prefix}-logs-data"
  metrics_bucket_name = "${var.prefix}-metrics-data"
}

module "buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.15.2"
  bucket_configs = [
    {
      bucket_name            = local.logs_bucket_name
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
    },
    {
      bucket_name            = local.metrics_bucket_name
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
    }
  ]
}

########################################################################################################################
# IBM Cloud Logs
########################################################################################################################

#
# Developer tips:
#   - Call the local module / modules in the example to show how they can be consumed
#   - include the actual module source as a code comment like below so consumers know how to consume from correct location
#

locals {
  cloud_logs_instance_name = "${var.prefix}-cloud-logs"
}

module "cloud_logs" {
  source = "terraform-ibm-modules/cloud-logs/ibm"
  version = "1.13.3"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  instance_name     = local.cloud_logs_instance_name

  data_storage = {
    # logs and metrics buckets must be different
    logs_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.logs_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.logs_bucket_name].s3_endpoint_direct
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.metrics_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.metrics_bucket_name].s3_endpoint_direct
    }
  }
}

##############################################################################
# Cloud Monitoring
##############################################################################

module "cloud_monitoring" {
  source            = "terraform-ibm-modules/cloud-monitoring/ibm"
  version           = "1.15.3"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  instance_name     = "${var.prefix}-cloud-monitoring"
  plan              = "graduated-tier"
}

########################################################################################################################
# VPC + Subnet + Public Gateway
#
# NOTE: This is a very simple VPC with single subnet in a single zone with a public gateway enabled, that will allow
# all traffic ingress/egress by default.
# For production use cases this would need to be enhanced by adding more subnets and zones for resiliency, and
# ACLs/Security Groups for network security.
########################################################################################################################

resource "ibm_is_vpc" "vpc" {
  name                      = "${var.prefix}-vpc"
  resource_group            = module.resource_group.resource_group_id
  address_prefix_management = "auto"
}

resource "ibm_is_public_gateway" "gateway" {
  name           = "${var.prefix}-gateway-1"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = module.resource_group.resource_group_id
  zone           = "${var.region}-1"
}

resource "ibm_is_subnet" "subnet_zone_1" {
  name                     = "${var.prefix}-subnet-1"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = module.resource_group.resource_group_id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.gateway.id
}

locals {

  cluster_vpc_subnets = {
    default = [
      {
        id         = ibm_is_subnet.subnet_zone_1.id
        cidr_block = ibm_is_subnet.subnet_zone_1.ipv4_cidr_block
        zone       = ibm_is_subnet.subnet_zone_1.zone
      }
    ]
  }

  worker_pools = [
    {
      subnet_prefix    = "default"
      pool_name        = "default" # ibm_container_vpc_cluster automatically names default pool "default" (See https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2849)
      machine_type     = var.machine_type
      operating_system = "RHCOS"
      workers_per_zone = var.number_worker_nodes
    }
  ]
}

##############################################################################
# Create the cluster
##############################################################################
module "ocp_base" {
  source                              = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version                             = "3.87.0"
  resource_group_id                   = module.resource_group.resource_group_id
  region                              = var.region
  cluster_name                        = var.cluster_name == null ? "${var.prefix}-cluster" : var.cluster_name
  force_delete_storage                = true
  vpc_id                              = ibm_is_vpc.vpc.id
  vpc_subnets                         = local.cluster_vpc_subnets
  ocp_version                         = var.ocp_version
  worker_pools                        = local.worker_pools
  ocp_entitlement                     = null
  disable_outbound_traffic_protection = true
  use_existing_cos                    = true
  existing_cos_id                     = module.cos.cos_instance_id
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = module.ocp_base.cluster_id
  resource_group_id = module.resource_group.resource_group_id
}

locals {
  logs_agent_namespace = "ibm-observe"
  logs_agent_name      = "logs-agent"
}


module "trusted_profile" {
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "4.0.0"
  trusted_profile_name        = "${var.prefix}-profile"
  trusted_profile_description = "Logs agent Trusted Profile"
  # As a `Sender`, you can send logs to your IBM Cloud Logs service instance - but not query or tail logs. This role is meant to be used by agent and routers sending logs.
  trusted_profile_policies = [{
    roles             = ["Sender"]
    unique_identifier = "logs-agent"
    resources = [{
      service = "logs"
    }]
  }]
  # Set up fine-grained authorization for `logs-agent` running in ROKS cluster in `ibm-observe` namespace.
  trusted_profile_links = [{
    cr_type           = "ROKS_SA"
    unique_identifier = "logs-agent-link"
    links = [{
      crn       = module.ocp_base.cluster_crn
      namespace = local.logs_agent_namespace
      name      = local.logs_agent_name
    }]
    }
  ]
}

data "ibm_is_security_groups" "vpc_security_groups" {
  depends_on = [module.ocp_base]
  vpc_id     = ibm_is_vpc.vpc.id
}

# The below code creates a VPE for Cloud logs in the provisioned VPC which allows the agent to access the private Cloud Logs Ingress endpoint.
module "vpe" {
  source   = "terraform-ibm-modules/vpe-gateway/ibm"
  version  = "5.2.0"
  region   = var.region
  prefix   = var.prefix
  vpc_id   = ibm_is_vpc.vpc.id
  vpc_name = "${var.prefix}-vpc"
  subnet_zone_list = [
    {
      id   = ibm_is_subnet.subnet_zone_1.id
      name = ibm_is_subnet.subnet_zone_1.name
      zone = ibm_is_subnet.subnet_zone_1.zone
    }
  ]
  resource_group_id  = module.resource_group.resource_group_id
  security_group_ids = [for group in data.ibm_is_security_groups.vpc_security_groups.security_groups : group.id if group.name == "kube-${module.ocp_base.cluster_id}"] # Select only security group attached to the Cluster
  cloud_service_by_crn = [
    {
      crn          = module.cloud_logs.crn
      service_name = "logs"
    }
  ]
  service_endpoints = "private"
}

##############################################################################
# Logs Agent
##############################################################################

module "logs_agent" {
  source                    = "terraform-ibm-modules/logs-agent/ibm"
  version                   = "1.23.0"
  depends_on                = [module.vpe]
  cluster_id                = module.ocp_base.cluster_id
  cluster_resource_group_id = module.resource_group.resource_group_id
  # Logs agent
  logs_agent_trusted_profile_id = module.trusted_profile.trusted_profile.id
  logs_agent_namespace          = local.logs_agent_namespace
  logs_agent_name               = local.logs_agent_name
  cloud_logs_ingress_endpoint   = module.cloud_logs.ingress_private_endpoint
  storage_name                  = "${var.prefix}-storage"
  cloud_logs_ingress_port       = 443
  logs_agent_additional_metadata = [{
    key   = "cluster_id"
    value = module.ocp_base.cluster_id
  }]
  logs_agent_resources = {
    limits = {
      cpu    = "500m"
      memory = "3Gi"
    }
    requests = {
      cpu    = "100m"
      memory = "1Gi"
    }
  }
  logs_agent_system_logs = ["/logs/*.log"]
}

##############################################################################
# Monitoring Agents
##############################################################################

module "monitoring_agent" {
  source  = "terraform-ibm-modules/monitoring-agent/ibm"
  version = "1.24.0"
  cluster_id                = module.ocp_base.cluster_id
  cluster_resource_group_id = module.resource_group.resource_group_id
  is_vpc_cluster            = true
  access_key                = module.cloud_monitoring.access_key
  instance_region           = var.region
  # example of how to include / exclude container filter - more info https://cloud.ibm.com/docs/monitoring?topic=monitoring-change_kube_agent#change_kube_agent_filter_data
  container_filter = [{ type = "exclude", parameter = "kubernetes.namespace.name", name = "kube-system" }]
  # example of setting agent mode to troubleshooting for additional metrics
  agent_mode = "troubleshooting"
}

##############################################################################
# Postgresql
##############################################################################

module "database" {
  source              = "terraform-ibm-modules/icd-postgresql/ibm"
  version             = "4.12.3"
  resource_group_id   = module.resource_group.resource_group_id
  name                = "${var.prefix}-data-store"
  region              = var.region
  service_endpoints   = "private"
  deletion_protection = false
  admin_pass          = var.postgresql_admin_pword

  service_credential_names = [
    {
      name     = "postgresql_admin"
      role     = "Administrator"
      endpoint = "private"
    },
    {
      name     = "postgresql_operator"
      role     = "Operator"
      endpoint = "private"
    },
    {
      name     = "postgresql_viewer"
      role     = "Viewer"
      endpoint = "private"
    },
    {
      name     = "postgresql_editor"
      role     = "Editor"
      endpoint = "private"
    }
  ]
}

data "ibm_database_connection" "database_connection" {
  endpoint_type = "private"
  deployment_id = module.database.id
  user_id       = module.database.adminuser
  user_type     = "database"
}