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

module "do" {
  source       = "./do"
  nodes_count  = var.nodes_count
  cluster_name = var.cluster_name
}

resource "local_file" "kubeconfig" {
  depends_on = [module.do]
  content    = module.do.kubeconfig
  filename   = "./kubeconfig"
}

# this is essentially a hack, given the way providers are handled in terraform.
# see this: https://github.com/hashicorp/terraform/issues/2430#issuecomment-370685911
provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
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
  depends_on = [module.do]
  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}

resource "helm_release" "externaldns" {
  name       = "external-dns"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "external-dns"
  depends_on = [module.do]
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

output "kubeconfig" {
  value       = module.do.kubeconfig
  description = "Kubeconfig file contents"
}
