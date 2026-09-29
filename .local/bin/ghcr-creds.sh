#!/bin/bash

# Set credentials for ghcr.io
export GHCR_USERNAME="mbright@cpacketnetworks.com"
export GHCR_TOKEN="$(cat $HOME/.work-ghcr-token)"

# # Create Secret for ghcr.io (cilium-replicator)
# kubectl create secret docker-registry cilium-replicator \
#   --docker-server=ghcr.io \
#   --docker-username="$GHCR_USERNAME" \
#   --docker-password="$GHCR_TOKEN" \
#   --namespace=kube-system
#
# # Create Secret for ghcr.io
# kubectl create secret docker-registry cpacket-token \
#   --docker-server=ghcr.io \
#   --docker-username="$GHCR_USERNAME" \
#   --docker-password="$GHCR_TOKEN" \
#   --namespace=default

kubectl create secret docker-registry ghcr-token \
  --docker-server=ghcr.io \
  --docker-username="$GHCR_USERNAME" \
  --docker-password="$GHCR_TOKEN" \
  --namespace=default
