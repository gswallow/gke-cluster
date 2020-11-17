data "google_compute_regions" "available" {}

data "google_compute_zones" "available" {
  region = var.gcp_region
  project = var.project_id
}

data "google_project" "project" {
  project_id = var.project_id
}

data "google_project" "shared_vpc_host" {
  project_id = var.network_project_id
}

data "google_compute_network" "current" {
  name = var.network_name
  project = var.network_project_id
}

locals {
  chosen_subnetwork = element(regex("/([a-z0-9-]+)$", [ for subnetwork in data.google_compute_network.current.subnetworks_self_links: subnetwork if length(regexall(var.gcp_region, subnetwork)) > 0 ][0]), 0)
}