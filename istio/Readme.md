# Istio

Run these commands to install and setup Istio -

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add kiali https://kiali.org/helm-charts
helm repo update

# installing Istio
helm install istio-base istio/base -n istio-system --create-namespace
helm install istiod istio/istiod -n istio-system --wait

# installing Kiali dashboard
helm install --namespace istio-system kiali-server kiali/kiali-server --set auth.strategy="anonymous" --wait

# installing Istio integrations - `Jaeger` for distributed tracing and `Prometheus` and `Grafana` for monitoring
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/jaeger.yaml"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/prometheus.yaml"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/grafana.yaml"

# installing Istio ingress gateway
helm install istio-ingressgateway istio/gateway -n istio-system --wait

# enabling Istio sidecar injection in the `default` namespace
kubectl label namespace default istio-injection=enabled
```

You can access Kiali dashboard at https://loacalhost:20001 by running this command -

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

## Exposing whoami application

First, lets deploy the whoami application at **../traefik-with-kubernetes-gateway-api/applications/whoami** by running -

```bash
kubectl apply -f ../traefik-with-kubernetes-gateway-api/applications/whoami
```

Now, we will create a *`Gateway`* and a *`VirtualService`* to expose this application. Run these commands -

```bash
kubectl apply -f ./manifests/gateway.yaml
kubectl apply -f ./manifests/whoami.virtualservice.yaml
```

The whoami application now is accessible at http://whoami.127.0.0.1.nip.io/