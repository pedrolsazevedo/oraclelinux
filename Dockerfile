FROM oraclelinux:9 AS base

RUN dnf update -y \
    && dnf upgrade -y \
    && dnf clean all \
  	&& rm -rf /var/cache/yum

## Install Terraform
RUN dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN dnf update -y
RUN dnf -y install terraform

## Install OCI
RUN dnf -y install oraclelinux-developer-release-el9
RUN dnf install python39-oci-cli

WORKDIR /terraform
CMD [ "/bin/bash" ] 


# Build the image for amd64 architecture
FROM base AS amd64
ARG OPENSSL_VERSION
RUN echo "Building for amd64 architecture"
RUN uname -m
RUN openssl version
LABEL org.label-schema.architecture="amd64"
LABEL org.label-schema.version="tf-oci"
LABEL org.label-schema.description="Terraform and OCI CLI on Oracle Linux (amd64)"
COPY README.md /

# Build the image for arm64 architecture
FROM base AS arm64
ARG OPENSSL_VERSION
RUN echo "Building for arm64 architecture"
RUN uname -m
RUN openssl version
LABEL org.label-schema.architecture="arm64"
LABEL org.label-schema.version="tf-oci"
LABEL org.label-schema.description="Terraform and OCI CLI on Oracle Linux (arm64)"
COPY README.md /

# Set multi-architecture labels
LABEL org.label-schema.architecture="multi-platform"
LABEL org.label-schema.version="tf-oci"
LABEL org.label-schema.description="Terraform and OCI CLI on Oracle Linux (multi-platform)"

# Create a manifest list to include both images
FROM scratch AS manifest
COPY --from=amd64 / /
COPY --from=arm64 / /
LABEL org.label-schema.architecture="multi-platform"
LABEL org.label-schema.version="tf-oci"
LABEL org.label-schema.description="Terraform and OCI CLI on Oracle Linux (multi-platform)"
CMD [ "cat", "/README.md" ]

# Use the manifest command to create a single image that can run on multiple architectures
FROM manifest AS final
