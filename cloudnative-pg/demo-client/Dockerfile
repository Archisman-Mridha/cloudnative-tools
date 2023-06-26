FROM golang:1.20-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o cloudnative-pg-demo-client

#*--

FROM alpine AS packager
WORKDIR /

COPY --from=builder /app/cloudnative-pg-demo-client .
ENTRYPOINT [ "./cloudnative-pg-demo-client" ]