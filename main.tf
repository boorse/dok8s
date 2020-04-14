variable "do_token" {
  type        = string
  description = "DigitalOcean API Token"
}

variable "nodes_count" {
  type        = number
  description = "The number of nodes to initialize in the cluster"
}

variable "cluster_name" {
  type        = string
  description = "The cluster name"
}

provider "digitalocean" {
  token = var.do_token
}

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

provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.dok8scluster.endpoint
    token = digitalocean_kubernetes_cluster.dok8scluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.dok8scluster.kube_config[0].cluster_ca_certificate)
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "ingress" {
  name       = "nginx-ingress"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "nginx-ingress"
  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}

resource "helm_release" "externaldns" {
  name       = "external-dns"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "external-dns"
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "provider"
    value = "digitalocean"
  }
  set {
    name  = "digitalocean.apiToken"
    value = var.do_token
  }
  set {
    name  = "interval"
    value = "1m"
  }
  set {
    name  = "policy"
    value = "sync"
  }
}
