deploy-rabbitmq:
# installing the rabbitMQ cluster operator
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm install rabbitmq bitnami/rabbitmq-cluster-operator

# creating the rabbitMQ cluster
	kubectl apply -k ./kubernetes/rabbitmq

build-and-push-container-images:
	docker build -t archismanmridha/rabbitmq-receiver-microservice:1.0.0 -f ./dockerfiles/receiver.dockerfile . && \
		docker push archismanmridha/rabbitmq-receiver-microservice:1.0.0
	docker build -t archismanmridha/rabbitmq-sender-microservice:1.0.0 -f ./dockerfiles/sender.dockerfile . && \
		docker push archismanmridha/rabbitmq-sender-microservice:1.0.0