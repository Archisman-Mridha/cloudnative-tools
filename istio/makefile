#* installing istio along with the kiali dashboard
install-istio:
	helm repo add istio https://istio-release.storage.googleapis.com/charts
	helm repo add kiali https://kiali.org/helm-charts
	helm repo update

	helm install istio-base istio/base -n istio-system --create-namespace
	helm install istiod istio/istiod -n istio-system --wait

	helm install --namespace istio-system kiali-server kiali/kiali-server --set auth.strategy="anonymous"

# labeling the namespaces
	kubectl label namespace dev istio-injection=enabled