FROM golang:1.19 AS builder

WORKDIR /usr/local/go/src

COPY ./services/sender/go.mod ./services/sender/
COPY ./services/sender/go.sum ./services/sender/

COPY ./shared/go.mod ./shared/
COPY ./shared/go.sum ./shared/

#* creating a workspace file and registering the modules
RUN go work init && \
    go work use ./services/sender && \
    go work use ./shared && \
    go work sync

#* resolving dependencies of modules

RUN cd ./services/sender && \
    go mod download

RUN cd ./shared && \
    go mod download

#* copying the main module
COPY ./services/sender/* ./services/sender/

#* copying the library module containing shared code
COPY ./shared/* ./shared/

RUN go build -o build ./services/sender

FROM alpine:latest AS packager

WORKDIR /

COPY --from=builder /app/build .

EXPOSE 4000

ENTRYPOINT [ "build" ]