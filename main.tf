variable "do_token" {
  type = string
  description = "DigitalOcean API Token"
}

variable "nodes_count" {
  type = number
  description = "The number of nodes to initialize in the cluster"
}

variable "cluster_name" {
  type = string
  description = "The cluster name"
}

variable "project_name" {
  type = string
  description = "The project to create the new cluster in"
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "dok8scluster" {
  name    = var.cluster_name
  region  = "nyc1"
  # Check for latest version using `doctl kubernetes options versions`
  version = "1.16.6-do.2"

  node_pool {
    name       = "primary-worker-pool"
    # Check for compute instance sizes using `doctl compute size list`
    size       = "s-2vcpu-4gb"
    node_count = var.nodes_count
  }
}

resource "digitalocean_project" "doproject" {
  name = var.project_name
  resources = [digitalocean_kubernetes_cluster.dok8scluster.id]
}