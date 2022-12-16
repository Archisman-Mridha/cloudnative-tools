show-argocd-ui:
	echo -n "" >> ./terraform/argo/installations/argocd-server-password.txt

	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d \
		>> ./terraform/argo/installations/argocd-server-password.txt

# kubectl port-forward svc/argocd-server -n argocd 8080:443

show-argo-workflows-ui:
	kubectl -n argo port-forward deployment/argo-server 2746:2746