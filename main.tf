resource "random_id" "kms" {
  byte_length = 3
}

resource "google_project_iam_member" "k8s_developer" {
  provider = google-beta
  count    = length(var.k8s_developers)
  role     = "roles/container.developer"
  project  = data.google_project.project.project_id
  member   = element(var.k8s_developers, count.index)
}

resource "google_project_iam_member" "kms_encrypter_decrypter" {
  provider   = google-beta
  project    = data.google_project.project.project_id
  role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member     = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_key_ring" "etcd" {
  name     = "gke-${var.cluster_name}-${random_id.kms.hex}"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "etcd" {
  name            = "gke-${var.cluster_name}-etcd-${random_id.kms.hex}"
  key_ring        = google_kms_key_ring.etcd.id
  rotation_period = "2592000s"

  depends_on = [ google_project_iam_member.kms_encrypter_decrypter, google_bigquery_dataset.k8s_resource_usage ]
  
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_dataset" "k8s_resource_usage" {
  count                       = var.enable_resource_consumption_export ? 1 : 0
  dataset_id                  = local.resource_usage_export_dataset_id
  friendly_name               = local.resource_usage_export_dataset_id
  description                 = "Kubernetes resource usage for the ${var.cluster_name} GKE cluster"
  default_table_expiration_ms = 31209600000
  delete_contents_on_destroy  = true

  labels = {
    env = var.project_id
  }

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role   = "READER"
    domain = var.org_domain
  }
}

# impersonate_service_account is not yet released, so use a ref spec.
module "kubernetes-engine" {
  source                             = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  project_id                         = var.project_id
  name                               = var.cluster_name
  description                        = var.cluster_description
  kubernetes_version                 = var.kubernetes_version#
  region                             = var.gcp_region
  zones                              = data.google_compute_zones.available.names
  network                            = var.network_name
  network_project_id                 = var.network_project_id
  subnetwork                         = local.chosen_subnetwork
  enable_pod_security_policy         = var.enable_pod_security_policy
  enable_private_nodes               = var.enable_private_nodes
  enable_vertical_pod_autoscaling    = var.enable_vertical_pod_autoscaling
  ip_range_pods                      = "gke-pods"
  ip_range_services                  = "gke-services"
  add_cluster_firewall_rules         = var.add_cluster_firewall_rules
  cloudrun                           = var.cloudrun
  cloudrun_load_balancer_type        = var.cloudrun_load_balancer_type
  cluster_autoscaling                = var.cluster_autoscaling
  cluster_resource_labels            = var.labels
  create_service_account             = var.create_service_account
  impersonate_service_account        = var.terraform_service_account
  database_encryption                = [{
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.etcd.id
  }]
  default_max_pods_per_node          = var.default_max_pods_per_node
  enable_binary_authorization        = var.enable_binary_authorization
  enable_network_egress_export       = var.enable_network_egress_export
  enable_resource_consumption_export = var.enable_resource_consumption_export
  enable_shielded_nodes              = var.enable_shielded_nodes
  firewall_inbound_ports             = var.firewall_inbound_ports
  gce_pd_csi_driver                  = var.gce_pd_csi_driver
  grant_registry_access              = var.grant_registry_access
  horizontal_pod_autoscaling         = var.horizontal_pod_autoscaling
  http_load_balancing                = var.http_load_balancing
  istio                              = var.istio
  istio_auth                         = var.istio_auth
  logging_service                    = var.logging_service
  maintenance_start_time             = var.maintenance_start_time
  maintenance_recurrence             = var.maintenance_recurrence
  maintenance_end_time               = var.maintenance_end_time
  master_authorized_networks         = var.master_authorized_networks
  monitoring_service                 = var.monitoring_service
  network_policy                     = var.network_policy
  network_policy_provider            = var.network_policy_provider
  registry_project_id                = var.registry_project_id
  release_channel                    = var.release_channel
  remove_default_node_pool           = var.remove_default_node_pool
  resource_usage_export_dataset_id   = local.resource_usage_export_dataset_id
  service_account                    = var.service_account
  stub_domains                       = var.stub_domains
  upstream_nameservers               = var.upstream_nameservers

  node_pools                         = var.node_pools
  node_pools_oauth_scopes            = var.node_pools_oauth_scopes
}
