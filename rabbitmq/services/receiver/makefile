protoc-generate:
	rm -rf ./proto/generated
	mkdir ./proto/generated

	protoc --go_out=./proto/generated \
		--go_opt=paths=source_relative \
		--proto_path=./proto ./proto/rabbitmq.proto