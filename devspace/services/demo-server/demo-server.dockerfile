#* 👉 build the binary

FROM golang:1.19-alpine AS builder
WORKDIR /app

COPY . .

RUN go build -o build

#* 👉 package the binary

FROM alpine:latest AS packager

COPY --from=builder /app/build .

EXPOSE 4000
CMD ["./build"]