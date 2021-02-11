#!/bin/bash

kubectl create namespace argocd
kubectl apply -n argocd -f ./argocd

# Set fixed password
# Password: admin
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$k.6AIfusiYu8z3BMKYcfLuolH/IeiHESZxCjC68TbPk254gYodAgm",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

# use the following
cat config-argocd.yml | \
sed "s/HOSTIP/$(minikube -p sample-argocd-keycloak ip)/" | \
kubectl apply -f -