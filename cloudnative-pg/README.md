# Cloudnative PG

Prerequisite commands -

```sh
# Install the Cloudnative PG operator
kubectl apply -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.20/releases/cnpg-1.20.1.yaml

# Install Atlas Kubernetes operator
helm install atlas-operator oci://ghcr.io/ariga/charts/atlas-operator
```