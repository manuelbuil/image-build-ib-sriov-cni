ARG TAG="v1.0.0"
ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.15.8b5

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x \
 && apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/ib-sriov-cni
WORKDIR ib-sriov-cni
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG} 
RUN make clean && make build 

# Create the sriov-cni image
FROM ${UBI_IMAGE}
WORKDIR /
COPY --from=builder /go/ib-sriov-cni/images/entrypoint.sh /
COPY --from=builder /go/ib-sriov-cni/build/ib-sriov-cni /usr/bin/
ENTRYPOINT ["/entrypoint.sh"]
