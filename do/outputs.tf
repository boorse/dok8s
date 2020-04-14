output "kubeconfig" {
  value       = digitalocean_kubernetes_cluster.dok8scluster.kube_config[0].raw_config
  description = "Kubeconfig file contents"
}
