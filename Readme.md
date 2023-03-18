# Exploring Cloudnative tools

- [x] `Kubernetes Dashboard` - For monitoring a Kubernetes cluster \
	Deployed Kubernetes Dashboard using Terraform and Helm charts

- [x] `DevSpace` - For Kubernetes native development workflow \
	Experimented with a simple Go application

- [x] `Traefik` - For exposing applications outside the Kubernetes cluster \
	Exposed Traefik Dashboard itself and another sample application using Kubernetes Ingress provider

- [x] `Kubernetes Gateway API` - Better replacement of NGINX and Ingress \
	Used the HTTPRoute resource to expose a sample application using Traefik as the reverse proxy

- [x] `Bitnami Sealed Secrets` - Storing Kubernetes Secrets encrypted in Github to leverage GitOPs advantages \
	Generated Sealed Secret manifest file from existing Kubernetes Secret manifest file

- [x] `CockroachDB with goLang Migrate` - Distributed SQL database (CockroachDB) with a database migration tool (goLang Migrate) \
	Ran migrations for a cockroachDB cluster running in the cloud

- [x] `Argo Ecosystem` - For creating fully automated Kubernetes native CI/CD pipelines based on GitOps principles \
	Created an end to end CI/CD pipeline to deploy a server

	You can find the code in this repository - https://github.com/Archisman-Mridha/kubernetes-cicd-with-argo

- [x] `RabbitMQ` - For inter-service communication using Advanced Message Queue Protocol (AMQP)
	Made 2 microservices communicate with each other using the AMQP protocol and the message was marshelled / unmarshalled using `protobuf`.

- [x] `Istio Service Mesh`

	> Initially I had plans to use the `Cilium Service Mesh` which is based on the eBPF technology. I use WSL2 and currently I am having problems running eBPF programs and Cilium in WSL2. So intead, I will explore `Istio` for temporary usage.

- [ ] `Observability` -
	+ `Jaeger` with `OpenTelemetry` for instrumenting my code and distributed tracing
	+ `Prometheus` with `Grafana` for visualizing metrics
	+ `ElasticSearch`, `LogStash` and `Kibanna` for logging

- [ ] `Testing` -
	+ `kubernetes-e2e framework` for performing end to end tests inside Kubernetes
	+ `K6 Load testing` for performing load tests
	+ `Litmus Chaos` for chaos testing

- [ ] `Cert Manager` - Automated TLS certificate management in Kubernetes