variable "gcp_region" {
  description = "The Google Cloud region in which to create resources"
  type        = string
  default     = "us-central1"
}

variable "org_domain" {
  description = "The organization in charge of created resources"
  type        = string
  default     = "gregongcp.net"
}

variable "billing_account_id" {
  description = "The ID of the billing account with which to associate this project"
  type        = string
}

variable "terraform_service_account" {
  description = "The service account to use for Terraform"
  type        = string
}

variable "labels" {
  description = "Extra tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "cluster_description" {
  description = "The description of the cluster"
  type        = string
  default     = "Managed by Terraform"
}

variable "project_id" {
  description = "The project in which to create the cluster"
  type        = string
}

variable "network_name" {
  description = "The name of the network to use"
  type = string
}

variable "network_project_id" {
  description = "The project ID of the shared VPC's host"
  type = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to install"
  type        = string
  default     = "latest"
}

variable "add_cluster_firewall_rules" {
  description = "Whether to automatically add cluster firewall rules for cluster ingress"
  type        = bool
  default     = true
}

variable "cluster_autoscaling" {
  description = "Enable cluster autoscaling"
  type = object({
    enabled       = bool
    min_cpu_cores = number
    max_cpu_cores = number
    min_memory_gb = number
    max_memory_gb = number
  })
  default = {
    enabled       = false
    max_cpu_cores = 0
    min_cpu_cores = 0
    max_memory_gb = 0
    min_memory_gb = 0
  }
}

variable "create_service_account" {
  description = "Create a service account to run nodes"
  type        = bool
  default     = false
}

variable "default_max_pods_per_node" {
  description = "The maximum number of pods to run per node."
  type        = number
  default     = 110
}

variable "enable_binary_authorization" {
  description = "Enable BinAuthZ Admission controller"
  type        = bool
  default     = false
}

variable "enable_network_egress_export" {
  description = "If enabled, a daemonset will be created in the cluster to meter network egress traffic"
  type        = bool
  default     = false
}

variable "enable_resource_consumption_export" {
  description = "When enabled, a table will be created in the resource export BigQuery dataset to store resource consumption data"
  type        = bool
  default     = false
}

variable "enable_shielded_nodes" {
  description = "Enable shielded nodes features on all nodes in the cluster"
  type        = bool
  default     = true
}

variable "firewall_inbound_ports" {
  description = "List of TCP ports for admission/webhook controllers"
  type        = list(string)
  default     = []
}

variable "grant_registry_access" {
  description = "Grants created cluster-specific service account storage.objectViewer role"
  type        = bool
  default     = true
}

variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling addon"
  type        = bool
  default     = false
}

variable "http_load_balancing" {
  description = "Enable HTTP load balancer addon"
  type        = bool
  default     = true
}

variable "logging_service" {
  description = "The logging service to write logs to. Options include logging.googleapis.com, logging.googleapis.com/kubernetes, and none"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "maintenance_start_time" {
  description = "Time window for daily or recurring maintenance operations"
  type        = string
  default     = "05:00"
}

variable "master_authorized_networks" {
  description = "List of master authorized networks. If none are provided, disallow external access."
  type        = list(object({ cidr_block = string, display_name = string }))
  default     = []
}

variable "monitoring_service" {
  description = "The monitoring service to send data to."
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "network_policy" {
  description = "Enable network policy addon"
  type        = bool
  default     = true
}

variable "network_policy_provider" {
  description = "The network policy provider to enable"
  type        = string
  default     = "CALICO"
}

variable "node_pools" {
  description = "A list of node pools to create"
  type        = list(map(string))
  default     = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 10
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 1
    },
  ]
}

variable "registry_project_id" {
  description = "The host project of the google container registry. If empty, use the cluster project"
  type        = string
  default     = ""
}

variable "release_channel" {
  description = "The release channel of this cluster. Accepted values are UNSPECIFIED, RAPID, REGULAR and STABLE"
  type        = string
  default     = "REGULAR"
}

variable "remove_default_node_pool" {
  description = "Remove the default node pool when creating the cluster"
  type        = bool
  default     = true
}

variable "service_account" {
  description = "The service account to run nodes as if not overridden in node_pools"
  type        = string
  default     = ""
}

variable "stub_domains" {
  description = "Map of stub domains and their resolvers to forward DNS queries for a certain domain to an external DNS server"
  type        = map(list(string))
  default     = {}
}

variable "upstream_nameservers" {
  description = "If specified, the values replace the nameservers taken by default from the node’s /etc/resolv.conf"
  type        = list(string)
  default     = []
}

variable "k8s_developers" {
  description = "List of Google user accounts (or groups) that may deploy to the GKE cluster"
  type = list(string)
  default = []
}

locals {
  labels = merge(
    {
      OrganizationId = var.org_domain
      BillingAccount = var.billing_account_id
    },
  var.labels)
}
