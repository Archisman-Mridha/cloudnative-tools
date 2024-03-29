create-cluster:
	k3d cluster create cloudnative-tools-testing --config ./cluster.config.yaml

start-cluster:
	k3d cluster start cloudnative-tools-testing

stop-cluster:
	k3d cluster stop cloudnative-tools-testing

delete-cluster:
	k3d cluster delete cloudnative-tools-testing

deploy-kubernetes-dashboard:
	cd ./kubernetes-dashboard/terraform && terraform init && \
		terraform apply

	kubectl proxy