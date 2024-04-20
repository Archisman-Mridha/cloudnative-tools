# Cilium Cluster Mesh

The `Koornacht` cluster is using `10.1.0.0/16` for the pod network and `172.20.1.0/24` for the Kubernetes services. Install Cilium in it and enable the `Cluster Mesh` feature :
```sh
cilium install \
  --set cluster.name=koornacht \
  --set cluster.id=1 \
  --set ipam.mode=kubernetes

## Wait for Cilium installation to complete.
cilium status --wait

## Several types of connectivity can be set up. We're using NodePort in our case as it's easier and
## we don't have dynamic load balancers available. For production clusters, it is strongly
## recommended to use LoadBalancer instead.
cilium clustermesh enable --service-type NodePort

## Wait for ClusterMesh feature to be ready.
cilium clustermesh status --wait
```

You can do the same (use `cluster.id=2` during Cilium installation) in the `Tion` cluster which is using `10.2.0.0/16` for the pod network and `172.20.2.0/24` for the Kubernetes Services.

> All clusters must use Cilium as the CNI to use the Cluster Mesh feature. A cluster will only get read-only access to other clusters.

Now let's mesh the clusters :
```sh
cilium clustermesh connect \
  --context kind-koornacht \
  --destination-context kind-tion

## Wait for the cluster meshing process to be complete.
cilium clustermesh status --wait
```