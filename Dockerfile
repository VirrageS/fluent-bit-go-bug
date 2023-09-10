FROM golang:1.21-bullseye AS builder

RUN apt-get update && apt-get install -y make ca-certificates gcc && update-ca-certificates

WORKDIR /go/src/plugin/
RUN go install golang.org/dl/gotip@latest
RUN echo "y" | gotip download 525455

COPY . .
RUN CGO_ENABLED=1 gotip build -buildmode=c-shared -o bin/out_gstdout.so


FROM fluent/fluent-bit:2.1.8-debug AS base

COPY --from=builder /go/src/plugin/bin/out_gstdout.so /fluent-bit/plugins/
COPY --from=builder /go/src/plugin/etc/ /fluent-bit/etc/
