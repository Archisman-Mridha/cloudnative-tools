# Learning istio

I have followed this udemy course - https://www.udemy.com/course/istio-hands-on-for-kubernetes/ for learning Istio initially. You can find my notes here - https://www.notion.so/instagram-clone-project/Istio-76aa2bab64044903b94bb23498b69d25.

## Installation

First we will install **`istio`** using Helm. These are the commands -

```sh
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm install istio-base istio/base -n istio-system --create-namespace
helm install istiod istio/istiod -n istio-system
```

Next, we will install **`kiali`** which is a dashboard for istio. These are the commands -

```sh
helm repo add kiali https://kiali.org/helm-charts
helm repo update

helm install -n istio-system kiali-server kiali/kiali-server --set auth.strategy="anonymous"
```

Lastly, we will register the namespaces where sidecar injection by istio will be enabled, by labelling them. In this case, we want to enable sidecar injection in only the default namespace.

```sh
kubectl label namespace default istio-injection=enabled
```