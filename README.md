# DOK8S

Provision a DigitalOcean Kubernetes cluster with Terraform!

Resources created:

- DigitalOcean Kubernetes cluster with a configurable name, region, node droplet size, and number of nodes
- Helm charts for [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) and [external-dns](https://github.com/helm/charts/tree/master/stable/external-dns)

This accomplishes the setup steps from these two tutorials on DigitalOcean: [here](https://www.digitalocean.com/community/tutorials/how-to-automatically-manage-dns-records-from-digitalocean-kubernetes-using-externaldns) and [here](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm)

## Prerequisites

In order for this to work, you will need to [generate a DigitalOcean API Token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/) and have it handy.

## Instructions

Clone this repository:

```sh
git clone https://github.com/boorse/dok8s.git
cd dok8s/
```

Initialize the Terraform providers:

```sh
terraform init
```

Apply changes, providing custom values where needed. See the next section for a list of variables available.

```sh
# provide custom values for DO_API_TOKEN, MY_CLUSTER_NAME, etc
terraform apply -var do_token=$DO_API_TOKEN -var nodes_count=3 -var $MY_CLUSTER_NAME -var node_size=$SIZE -var cluster_region=$DO_REGION
```

Applying changes should take 6-7 minutes in total. Once this has completed, there should be a file in the root directory called `kubeconfig` that can be used to access the cluster using kubectl.

To access the cluster:

```sh
# copy to default kubeconfig location
cp ./kubeconfig ~/.kube/config

# test access
kubectl get all 
```

## Input Variables

The following variables are used to configure Terraform. They can be passed into the `terraform apply` command using the `-var` flag.

| Name           | Description                                                  | Type   |
| -------------- | ------------------------------------------------------------ | ------ |
| do_token       | DigitalOcean API Token                                       | string |
| nodes_count    | The number of nodes to initialize in the cluster             | number |
| node_size      | Size of droplets to create in the cluster node pool. For example: `s-2vcpu-4gb`. A full list of droplet size slugs can be found with the `doctl compute size list` command. | string |
| cluster_region | Region to create cluster inside. For example: `nyc1`. A full list of region slugs can be found with the `doctl compute region list` command. | string |
| cluster_name   | The cluster name                                             | string |

