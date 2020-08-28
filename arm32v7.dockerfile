FROM alpine AS builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1



FROM arm64v8/golang:1.14.7-alpine3.11 AS gobuild
# Add QEMU
COPY --from=builder qemu-arm-static /usr/bin

WORKDIR /go/src/github.com/msiebhur/prometheus-mdns-sd/
COPY mdns.go go.mod go.sum ./
RUN GO111MODULES=on CGO_ENABLED=0 GOOS=linux go build -a -o mdns .

FROM arm64v8/alpine:3.11
# Add QEMU
COPY --from=builder qemu-arm-static /usr/bin
WORKDIR /root/
COPY --from=gobuild /go/src/github.com/msiebhur/prometheus-mdns-sd/mdns .
ENTRYPOINT ["./mdns"]
