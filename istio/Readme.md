# Istio

I am trying to integrate Istio with *`Traefik`* and *`Kubernetes Gateway API`*.

# Installation

First we will install Istio and *`Kiali`*. -

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add kiali https://kiali.org/helm-charts
helm repo update

helm install istio-base istio/base -n istio-system --create-namespace
helm install istiod istio/istiod -n istio-system --wait

helm install --namespace istio-system kiali-server kiali/kiali-server --set auth.strategy="anonymous"

# labeling the namespaces where Istio injection will be enabled
kubectl label namespace dev istio-injection=enabled
```

Next, we will install some Istio integrations - *`Jaeger`* for distributed tracing and *`Prometheus`* and *`Grafana`* for monitoring.

```bash
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/jaeger.yaml"

kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/prometheus.yaml"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/grafana.yaml"
```

Next, we will install Kubernetes Gateway API and Traefik -

```bash
kubectl apply -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.5.1/standard-install.yaml"

helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik --set experimental.kubernetesGateway.enabled=true traefik/traefik
```

After this we will enable mTLS in the **dev** namespace. In this namespace, our microservices will run. Just apply this manifest -

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication

metadata:
    name: peer-authentication
    namespace: dev

spec:
    mtls:
        mode: STRICT
```