#!/bin/bash
kubectl delete -n argocd job/configure-keycloak-job --ignore-not-found=true

cat ./configure-keycloak.yml | \
sed "s/HOSTIP/$(minikube -p sample-argocd-keycloak ip)/" | \
kubectl apply -n argocd -f -

kubectl wait -n argocd --for=condition=complete --timeout=60s job/configure-keycloak-job

export CLIENT_SECRET=`kubectl logs -n argocd $(kubectl get pods -n argocd -l keycloak --sort-by=.metadata.creationTimestamp -o 'jsonpath={.items[-1].metadata.name}') | tail -n 1`

kubectl patch secret argocd-secret -n argocd --type='json' -p="[{\"op\" : \"replace\" ,\"path\" : \"/data/oidc.keycloak.clientSecret\" ,\"value\" : \"${CLIENT_SECRET}\"}]"

cat ./patch-configmap.yml | \
sed "s/HOSTIP/$(minikube -p sample-argocd-keycloak ip)/" | \
kubectl -n argocd patch configmap argocd-cm -p "$(cat)"

cat ./patch-rbac.yml | \
kubectl -n argocd patch configmap argocd-rbac-cm -p "$(cat)"

kubectl -n argocd apply -f ./apps.yml

kubectl rollout restart -n argocd deployment/argocd-server

kubectl rollout status -n argocd deployment/argocd-server

./open-argo.sh
./open-keycloak.sh