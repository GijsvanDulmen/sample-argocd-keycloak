#!/bin/bash

# save from:
# https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/kubernetes-examples/keycloak.yaml
kubectl apply -n argocd -f ./keycloak

# ingress for keycloak
cat ingress-keycloak.yml | \
sed "s/KEYCLOAK_HOST/keycloak.$(minikube -p sample-argocd-keycloak ip).nip.io/" | \
kubectl apply -n argocd -f -

# Open "http://keycloak.$(minikube -p sample-argocd-keycloak ip).nip.io"

# do: https://argoproj.github.io/argo-cd/operator-manual/user-management/keycloak/

# client secret to base64
# echo -n '8cc58395-1f2d-402d-a849-af8025d2c552' | base64
# result: ZDk0NkNjktNWIzNy00ZTBmLTlmNGUtZmZjODc3MzIyM2Q1ADASSDASDASDSA

# use argocd-cm.yml for convience