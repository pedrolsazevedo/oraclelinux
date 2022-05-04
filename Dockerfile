FROM oraclelinux:8.5 AS oraclelinux-tf-oci

RUN dnf update -y && dnf upgrade -y

## Install Terraform
RUN dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN dnf update -y
RUN dnf -y install terraform

## Install OCI
RUN dnf -y install oraclelinux-developer-release-el8
RUN dnf -y install python36-oci-cli

WORKDIR /terraform