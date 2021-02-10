#!/bin/bash

set -e exit

minikube -p sample-argocd-keycloak start \
    --memory=5120 --cpus=4 --vm=true

minikube -p sample-argocd-keycloak addons enable ingress