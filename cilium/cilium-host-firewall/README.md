# Cilium Host Firewall

Install Cilium :
```sh
cilium install \
  --set hostFirewall.enabled=true \
  --set kubeProxyReplacement=strict \
  --set bpf.monitorAggregation=none

## Enable Hubble
cilium hubble enable

## Wait until the installation is complete.
cilium status --wait
```
> We need to use `Kube Proxy Replacement (KPR) mode`, as it is a requirement for the `Host Firewall feature`.

SSH servers are installed on the Kubernetes nodes. We will test accessing the nodes via SSH.

In terminal window 1, start observing traffic sent to nodes :
```sh
## 1 is the special identity used by Cilium to refer to Kubernetes nodes.
hubble observe --to-identity 1 --port 22 -f
```

In terminal window 2, test SSH connection to the Kubernetes nodes :
```sh
for node in $(docker ps --format '{{.Names}}'); do
  echo "==== Testing connection to node $node ===="
  IP=$(docker inspect $node -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
  nc -vz -w2 $IP 22
done
```

## Cilium endpoints

Exec into a Cilium node and list endpoints known to Cilium :
```sh
kubectl exec -it -n kube-system cilium-h7nfz -- cilium endpoint list
```
> NOTE : The line with label `reserved:host` represents the `localhost`.

> NOTE : The `host special identity` 1 is also applied to pods (with spec.hostNetwork: true) using host networking, so their traffic is indistinguishable from traffic associated with non-containerized workloads on the node.

## The NetworkPolicies

We want to enforce traffic requirements on our nodes - **only the control plane node can be accessed from outside the cluster using SSH**.
  * For `SSH (tcp/22)`, we'll use the control plane node as a `bastion host` to access other nodes.
  * We still need to access the `Kubernetes API server (tcp/6443)` on the control plane.
  * The nodes need to be able to talk to each other on `VXLAN (udp/8472)`.
Everything else should be denied by default.

> NOTE : Allowing traffic explicitely with NetworkPolicies results in all traffic for the same selector and direction being implicitely denied. As a result, denying all ingress traffic to the nodes would prevent access to the Kubernetes API server in this cluster. It is thus important to apply the API server access rule before we apply the default deny rule, otherwise you won't have access to the Kubernetes API server to apply new rules and you will lock yourself out of the cluster!

We will use `CiliumClusterwideNetworkPolicy` (or ccnp) resources. This type of Network Policies applies globally to the whole cluster instead of being restricted to a single namespace like standard NetworkPolicy resources.

Let's create the ccnp resources :
```sh
## To allow access to Kubernetes API server running on the Control Plane node.
kubectl apply -f allow.apiserver-access.networkpolicy.yaml

## To default deny all network traffic to the Kubernetes notes.
kubectl apply -f deny.node-network-traffic.networkpolicy.yaml
```

Now, we'll try to access the Kubernetes nodes via SSH :
```sh
for node in $(docker ps --format '{{.Names}}'); do
  echo "==== Testing connection to node $node ===="
  IP=$(docker inspect $node -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
  nc -vz -w2 $IP 22
done
```
All SSH connection attempts will fail due to the ccnp resources.

Let's create the ccnp resource which allows SSH access to control plane nodes and try again :
```sh
kubectl apply -f allow.control-plane-node-ssh.networkpolicy.yaml
```
This time, SSH attempt to only the control plane node will succeed and the others will fail.
