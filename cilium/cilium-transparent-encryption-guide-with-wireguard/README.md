# Cilium Transparent Encryption with WireGuard

First check whether the node kernels have support for `WireGuard` or not using `uname -ar`.
> WireGuard was integrated into the Linux kernel from version 5.6.

Install Cilium with `encryption in transit (using WireGuard)` (including `node-to-node encryption`) feature enabled :
```sh
cilium install --version 1.14.5 \
  --set encryption.enabled=true \
  --set encryption.type=wireguard \
  --set encryption.nodeEncryption=true

## Wait for the installation to finish.
cilium status --wait
```

* Each node automatically creates its own `encryption key-pair` and distributes its public key via the `network.cilium.io/wg-pub-key` annotation in the Kubernetes `CiliumNode` CR object.

* Each node's public key is then used by other nodes to decrypt and encrypt traffic from and to `Cilium-managed endpoints ` running on that node.

You can verify this by checking the annotation on the Cilium node `kind-worker2`, which contains its public key :
```sh
kubectl get ciliumnode kind-worker2 \
  -o jsonpath='{.metadata.annotations.network\.cilium\.io/wg-pub-key}'
```

Let's get into one of the Cilium agents on the `kind-worker2` node and verify that `encryption in transit` is working properly :
```sh
CILIUM_POD=$(kubectl -n kube-system get po -l k8s-app=cilium --field-selector spec.nodeName=kind-worker2 -o name)
echo $CILIUM_POD

kubectl -n kube-system exec -ti $CILIUM_POD -- bash

## Verify that Cilium-WireGuard integration is enabled.
> cilium status | grep Encryption
. Encryption: Wireguard [NodeEncryption: Disabled, cilium_wg0 (Pubkey: qCzNE4dZv6MsMgdk0xFlT8q72c3ZIArvtyFDNlly4gA=, Port: 51871, Peers: 3)]

## Install tcpdump.
apt-get update
apt-get -y install tcpdump

## Find one of the node's IP address.
ETH0_IP=$(ip a show eth0 | sed -ne '/inet 172\.18\.0/ s/.*inet \(172\.18\.0\.[0-9]\+\).*/\1/p')
echo $ETH0_IP
## Run tcpdump on the WireGuard interface ('cilium_wg0' by default), focusing on the traffic coming]
## from this IP.
> tcpdump -n -i cilium_wg0
. 13:25:46.932578 IP 172.18.0.2.37422 > 172.18.0.3.4240: Flags [P.], seq 1:102, ack 1, win 502, options [nop,nop,TS val 577444696 ecr 2757624425], length 101
```
