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

variable "cloudrun" {
  description = "Enable Cloud Run" 
  type        = bool
  default     = false
}

variable "cloudrun_load_balancer_type" {
  description = "Configure the Cloud Run load balancer type. External by default. Set to LOAD_BALANCER_TYPE_INTERNAL to configure as an internal load balancer"
  type        = string
  default     = ""
}

variable "cluster_autoscaling" {
  description = "Enable cluster autoscaling"
  type = object({
    enabled       = bool
    autoscaling_profile = string
    min_cpu_cores = number
    max_cpu_cores = number
    min_memory_gb = number
    max_memory_gb = number

  })
  default = {
    enabled       = false
    autoscaling_profile = "BALANCED"
    max_cpu_cores = 0
    min_cpu_cores = 0
    max_memory_gb = 0
    min_memory_gb = 0
  }
}

variable "create_service_account" {
  description = "Create a service account to run nodes"
  type        = bool
  default     = true
}

variable "default_max_pods_per_node" {
  description = "The maximum number of pods to run per node."
  type        = number
  default     = 16
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

variable "enable_pod_security_policy" {
  description = "If enabled, pods must be valid under a PodSecurityPolicy to be created"
  type        = bool
  default     = false
}

variable "enable_private_nodes" {
  description = "Whether nodes have internal IP addresses only"
  type        = bool
  default     = true
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

variable "enable_vertical_pod_autoscaling" {
  description = "Scale pods vertically (more RAM and CPU) depending on demand"
  type        = bool
  default     = false
}  

variable "firewall_inbound_ports" {
  description = "List of TCP ports for admission/webhook controllers"
  type        = list(string)
  default     = []
}

variable "gce_pd_csi_driver" {
  description = "Whether this cluster should enable the Google Compute Engine Persistent Disk Container Storage Interface (CSI) Driver"
  type        = bool
  default     = true
}

variable "grant_registry_access" {
  description = "Grants created cluster-specific service account storage.objectViewer role"
  type        = bool
  default     = true
}

variable "horizontal_pod_autoscaling" {
  description = "Enable horizontal pod autoscaling addon"
  type        = bool
  default     = true
}

variable "http_load_balancing" {
  description = "Enable HTTP load balancer addon"
  type        = bool
  default     = true
}

variable "istio" {
  description = "Enable Istio"
  type        = bool
  default     = false
}

variable "istio_auth" {
  description = "The authentication type between services in Istio"
  type        = string
  default     = "AUTH_MUTUAL_TLS"
}

variable "logging_service" {
  description = "The logging service to write logs to. Options include logging.googleapis.com, logging.googleapis.com/kubernetes, and none"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "maintenance_start_time" {
  description = "Time window for daily or recurring maintenance operations"
  type        = string
  default     = "2006-01-02T02:00:00Z"
}

variable "maintenance_recurrence" {
  description = "Frequency of the recurring maintenance window in RFC 5545 format"
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=SA,SU"
}

variable "maintenance_end_time" {
  description = "The end of the window for daily or recurring maintenance operations"
  type        = string
  default     = "2006-01-02T08:00:00Z"
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
      name                 = "default-node-pool"
      machine_type         = "e2-medium"
      min_count            = 1
      max_count            = 5
      local_ssd_count      = 0
      disk_size_gb         = 100
      disk_type            = "pd-standard"
      image_type           = "COS"
      auto_repair          = true
      auto_upgrade         = true
      preemptible          = false
      enable_secure_boot   = true
      max_surge            = 2
      max_unavailable      = 0
      initial_node_count   = 1
    },
  ]
}

variable "node_pools_oauth_scopes" {
  type        = map(list(string))
  description = "Map of lists containing node oauth scopes by node-pool name"
  default     = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
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
  resource_usage_export_dataset_id = replace("${var.project_id}-${var.cluster_name}-usage", "-", "_")
  labels = merge(
    {
      OrganizationId = var.org_domain
      BillingAccount = var.billing_account_id
    },
  var.labels)
}
