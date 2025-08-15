FROM golang:1.17.3-alpine3.15 AS build

ARG VERSION
ENV VERSION=${VERSION:-development}

# ENV LIBVIRT_EXPORTER_PATH=/libvirt-exporter
# ENV LIBXML2_VER=2.9.12

RUN apk add ca-certificates g++ git libnl-dev linux-headers make libvirt-dev libvirt && \
    wget https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.12.tar.xz -P /tmp && \
    tar -xf /tmp/libxml2-2.9.12.tar.xz -C /tmp/ && \
    cd /tmp/libxml2-2.9.12 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    mkdir -p /libvirt-exporter
WORKDIR /libvirt-exporter
COPY . .

RUN go build -ldflags="-X 'main.Version=${VERSION}'" -mod vendor

FROM alpine:3.15
RUN apk add ca-certificates libvirt
COPY --from=build /libvirt-exporter/libvirt-exporter /
EXPOSE 9177

ENTRYPOINT [ "/libvirt-exporter" ]
