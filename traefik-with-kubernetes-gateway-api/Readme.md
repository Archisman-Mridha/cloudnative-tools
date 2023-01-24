# Traefik with Kubernetes Gateway API

Traefik is an *`ingress controller`* like NGINX. And Kubernetes Gateway API acts like a *`provider`* enabling **RBAC integration with traffic routing**.

## Resources Used

I suggest going through these resources -

+ [How to get started with Traefik and Kubernetes Gateway Api](https://traefik.io/blog/getting-started-with-traefik-and-the-new-kubernetes-gateway-api/)

+ [Guides on creating Kubernetes Gateway API resources](https://gateway-api.sigs.k8s.io/guides/)

## Installation

First we will install Traefik and Kubernetes Gateway API. Run these commands -

```bash
kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.0" --wait

helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik --set experimental.kubernetesGateway.enabled=true \
    -n traefik --create-namespace traefik/traefik
```

Now, you can expose the Traefik dashboard to your localhost by running these commands -

```bash
kubectl port-forward \
    $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name -n traefik) \
        9000:9000 -n traefik
```

The traefik dashboard is now available at http://localhost:9000/dashboard/

## Exposing Traefik Dashboard

Lets say, we want to expose the Traefik dashboard permanently to the localhost, without port forwarding.

First, we need to create a Kubernetes Service for the Traefik dashboard, which you can find here - **./applications/traefik-dashboard/service.yaml**.

+ Now if we want to use *`Kubernetes Ingress as a provider`*, we can apply the manifest at **./providers/kubernetes-ingress/traefik-dashboard.ingress.yaml**.

+ If instead, we want to use *`Kubernetes Gateway API as a provider`*, we can apply the manifest at **./providers/kubernetes-gateway-api/traefik-dashboard.httproute.yaml**.

The dashboard can be accessed at http://dashboard.traefik.127.0.0.1.nip.io/dashboard/#/.

## Exposing a small application

We will try to expose a sample **whoami** application using Traefik and Kubernetes Gateway API as the provider.

First apply the manifests at **./applications/whoami**. This creates the Deployment and Service objects. Next, run these commands to create the *`GatewayClass`*, *`Gateway`* and *`HTTPRoute`* resources -

```bash
kubectl apply -f ./providers/kubernetes-gateway-api/gatewayclass.yaml
kubectl apply -f ./providers/kubernetes-gateway-api/gateway.yaml
kubectl apply -f ./providers/kubernetes-gateway-api/whoami.httproute.yaml
```

Now you can access the whoami application at http://whoami-new.127.0.0.1.nip.io/.

## Exposing Larger Applications