FROM golang:1.19-alpine AS builder

ENV GO111MODULE=on CGO_ENABLED=0
WORKDIR /ws

COPY services/sender/go.* services/sender/
COPY shared/go.* shared/

# NOTE: this is required because we dont copy the receiver
# otherwise we could copy the go.work
RUN go work init && go work use ./shared/ && go work use ./services/sender/

# resolving dependencies of modules
RUN cd ./services/sender && go mod download
RUN cd ./shared && go mod download

# copying the main module
COPY services/sender services/sender

# copying the library module containing shared code
COPY shared shared

RUN go build ./services/sender/

FROM alpine:latest AS packager
WORKDIR /
COPY --from=builder /ws/sender .
EXPOSE 4000
ENTRYPOINT [ "sender" ]