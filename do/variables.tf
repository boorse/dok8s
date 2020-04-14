variable "nodes_count" {
  type        = number
  description = "The number of nodes to initialize in the cluster"
}

variable "node_size" {
  type        = string
  description = "Size of compute instances to create in the cluster node pool"
}

variable "cluster_name" {
  type        = string
  description = "The cluster name"
}

variable "cluster_region" {
  type        = string
  description = "Region to create cluster inside."
}
