FROM golang:1.19-alpine AS builder

ENV GO111MODULE=on CGO_ENABLED=0
WORKDIR /workspace

COPY services/receiver/go.* services/receiver/
COPY shared/go.* shared/

# NOTE: this is required because we dont copy the receiver
# otherwise we could copy the go.work
RUN go work init && \
    go work use ./shared/ && go work use ./services/receiver/

# resolving dependencies of modules
RUN cd ./services/receiver && go mod download
RUN cd ./shared && go mod download

# copying the main module
COPY services/receiver services/receiver

# copying the library module containing shared code
COPY shared shared

RUN go build ./services/receiver/

FROM alpine:latest AS packager
WORKDIR /
COPY --from=builder /workspace/receiver .
EXPOSE 4000
ENTRYPOINT [ "receiver" ]