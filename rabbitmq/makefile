build-and-push-container-images:
	docker build -t archismanmridha/argo-events-sender-microservice:1.0.0 -f ./dockerfiles/sender.dockerfile .
	docker build -t archismanmridha/argo-events-receiver-microservice:1.0.0 -f ./dockerfiles/receiver.dockerfile .

	docker push archismanmridha/argo-events-sender-microservice:1.0.0
	docker push archismanmridha/argo-events-receiver-microservice:1.0.0

deploy-rabbitmq:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm install rabbitmq bitnami/rabbitmq-cluster-operator