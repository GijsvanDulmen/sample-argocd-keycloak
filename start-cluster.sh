#!/bin/bash

set -e exit

minikube -p sample-argocd-keycloak start \
    --memory=5120 --cpus=4 --vm=true

minikube -p sample-argocd-keycloak addons enable ingress

./install-argocd.sh
./install-keycloak.sh

# wait for both the be finished
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/keycloak -n argocd

# start a job which configures keycloak
./configure-keycloak.sh