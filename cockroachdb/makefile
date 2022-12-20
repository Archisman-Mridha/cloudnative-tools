download-cluster-cert:
	curl --create-dirs -o ./root.crt -O https://cockroachlabs.cloud/clusters/7d6f23bf-3d6c-421b-ac2f-5d16c988bea7/cert

generate-migration-files:
	migrate create -ext sql -dir ./migrations -seq $(sequence)

# migrate -database "<COCKROACH_CLUSTER_URL>" -path ./migrations up