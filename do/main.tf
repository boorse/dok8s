
resource "digitalocean_kubernetes_cluster" "dok8scluster" {
  name   = var.cluster_name
  region = "nyc1"
  # Check for latest version using `doctl kubernetes options versions`
  version = "1.16.6-do.2"

  node_pool {
    name = "primary-worker-pool"
    # Check for compute instance sizes using `doctl compute size list`
    size       = "s-2vcpu-4gb"
    node_count = var.nodes_count
  }
}
