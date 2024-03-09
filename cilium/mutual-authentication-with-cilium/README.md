# Mutual Authentication with Cilium

Make sure Cilium is installed using Helm and these values were used during the Helm installation :
```yaml
debug:
  enabled: true

authentication:
  mutual:
    spire:
      enabled: true
      install:
        enabled: true
```

This will :
  * enable `mutual TLS (mTLS) authentication`.
    > But it won't be applied until a `NetworkPolicy` applicable to the corresponding workloads has the `authentication.mode: required` setting.
  * set `4250` as the default **port where mutual handshakes will be performed**.
  * set `spiffe.cilium` as the default `SPIFFE Trust Domain`.
  * set `30s` as the default `SPIRE connection timeout`.

Deploy the `starwars` app and L3 / L4 / L7 `NetworkPolicy` (with `mTLS authentication` enabled) :
```sh
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/http-sw-app.yaml

## Verify that the Deployment is ready.
kubectl rollout status deployment deathstar -w

kubectl apply -f deathstar.network-policy.yaml

## Verify that Tie Fighters (Empire space ships) are allowed to land on the Death Star :
kubectl exec tiefighter -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

## Verify that even if Tie Fighters (Empire space ships) are compromised, Death Star can't be
## blownup :
kubectl exec tiefighter -- \
  curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port

## Verify that the X-Wing ship (belong to the Alliance) is denied access to the Death Star :
kubectl exec xwing -- \
  curl -s --connect-timeout 1 -XPOST deathstar.default.svc.cluster.local/v1/request-landing
```

## Cilium with SPIFF and SPIRE

Cilium uses `SPIRE` - which follows the `SPIFFE (Secure Production Identity Framework for Everyone)` specification, to provide the mTLS authentication feature.

Benefits of using the SPIRE :

* `Trustworthy identity issuance` :
  It ensures that each service in a distributed system receives a unique and verifiable identity, even in dynamic environments where services may scale up or down frequently.

* `Identity attestation` :
  It ensures that services can demonstrate their authenticity and integrity by providing verifiable evidence about their identity, such as digital signatures or cryptographic proofs.

* `Dynamic and scalable environments` :
  It supports automatic identity issuance, rotation, and revocation, which are critical in cloud-native architectures where services may be constantly deployed, updated, or retired.

SPIFFE provides an API model that allows workloads to request an identity from a central server. In our case, a workload means the same thing that a Cilium Security Identity does : **a set of pods described by a label set**.

You can understand the `SPIFFE-SPIRE workflow` here - https://www.uber.com/en-IN/blog/our-journey-adopting-spiffe-spire/.

SPIRE related healthcheck commands :
```sh
## Check health of SPIRE server.
kubectl exec -n cilium-spire spire-server-0 -c spire-server -- \
  /opt/spire/bin/spire-server healthcheck

## Check health of SPIRE agents.
kubectl exec -n cilium-spire spire-server-0 -c spire-server -- \
  /opt/spire/bin/spire-server agent list

## Verify that Cilium agent and operator have identities on the SPIRE server :
kubectl exec -n cilium-spire spire-server-0 -c spire-server -- \
  /opt/spire/bin/spire-server entry show -parentID spiffe://spiffe.cilium/ns/cilium-spire/sa/spire-agent

## Get Cilium identity of the deathstar pods (They'll have the same identity since they have the
## same set of labels).
IDENTITY_ID=$(kubectl get cep -l app.kubernetes.io/name=deathstar -o=jsonpath='{.items[0].status.identity.id}')
echo $IDENTITY_ID
## The SPIFFE ID that uniquely identifies a workload — is based on the Cilium identity. It follows
## the spiffe://spiffe.cilium/identity/$IDENTITY_ID format. The Cilium operator is responsible for
## creating SPIRE entries for each Cilium identity.
## Verify that deathstar pods have a registered SPIFFE identity on the SPIRE server :
kubectl exec -n cilium-spire spire-server-0 -c spire-server -- \
  /opt/spire/bin/spire-server entry show -spiffeID spiffe://spiffe.cilium/identity/$IDENTITY_ID
```

> NOTE - SPIRE Server uses `Kubernetes Projected Service Account Tokens (PSATs)` to verify the identity of SPIRE Agents.

## Observing mTLS authentication using Hubble

Run the pings again :

```sh
kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec xwing -- curl -s --connect-timeout 1 -XPOST deathstar.default.svc.cluster.local/v1/request-landing
```

We can observe the network flow between `xwing` and `deathstar` :
```sh
> hubble observe --type drop --from-pod default/xwing

output :
  default/xwing:34800 (ID:61926) <> default/deathstar-7848d6c4d5-n7lzq:80 (ID:23991) policy-verdict:none INGRESS DENIED (TCP Flags: SYN)
```

and between `tiefighter` and `deathstar` :
```sh
> hubble observe --type drop --from-pod default/tiefighter

output :
  default/tiefighter:53150 (ID:19440) <> default/deathstar-7848d6c4d5-n7lzq:80 (ID:23991) policy-verdict:L3-L4 INGRESS DENIED (TCP Flags: SYN; Auth: SPIRE)
  default/tiefighter:53150 (ID:19440) -> default/deathstar-7848d6c4d5-n7lzq:80 (ID:23991) policy-verdict:L3-L4 INGRESS ALLOWED (TCP Flags: SYN; Auth: SPIRE)
```

You'll observe that the first connection between `tiefighter` and `deathstar` is dropped due to `mTLS authentication handshake`.

## mTLS authentication workflow

1. A Network Policy with `authentication.mode: required` was created and will apply to traffic between identity `tiefighter` and identity `deathstar`.

2. First packet from `tiefighter` to `deathstar` is dropped and Cilium is notified to start the mTLS authentication process. Further packets will be dropped until mTLS auth has completed. (`Policy is requiring authentication` log)

3. The Cilium agent retrieves the identity for `tiefighter`, connects to the node where the `deathstar` pod is running and performs a mTLS authentication handshake. (`Validating Server SNI` and `Validated certificate` logs)

4. When the handshake is successful (`Successfully authenticated` log), mTLS authentication is now complete, and packets from `tiefighter` to `deathstar` will now flow until the network policy is removed or the entry expires (which is when the certificate does).