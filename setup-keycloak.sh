#!/bin/bash

# Usefull debugging
# ./kcadm.sh get clients -q clientId=argocd

#############################################
#### Do the following inside a pod shell ####
#############################################

cd /opt/jboss/keycloak/bin/
export BASE="https://argocd.192.168.64.20.nip.io"
./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password admin
./kcadm.sh create clients -r master -s clientId=argocd \
    -s "redirectUris=[\"${BASE}/auth/callback\"]" \
    -s "baseUrl=\"/applications\"" \
    -s "rootUrl=\"${BASE}\"" \
    -s "publicClient=false" \
    -i > clientid.txt

export CLIENT_ID=`cat clientid.txt`
export CLIENT_SCOPE=`./kcadm.sh create client-scopes -r master -s protocol=openid-connect -s name=groups -i`

# export CLIENT_SCOPE="475f5fa8-0a84-4580-874f-5b0f683dd58d"
./kcadm.sh create client-scopes/${CLIENT_SCOPE}/protocol-mappers/models -r master \
    -s name=groups \
    -s protocolMapper=oidc-group-membership-mapper \
    -s protocol=openid-connect \
    -s consentRequired=false \
    -s 'config."full.path"=false' \
    -s 'config."id.token.claim"=true' \
    -s 'config."access.token.claim"=true' \
    -s 'config."claim.name"=groups' \
    -s 'config."userinfo.token.claim"=true'

# Add scope to client
./kcadm.sh update clients/${CLIENT_ID} -r master -s "defaultClientScopes=[\"groups\"]"
./kcadm.sh update clients/${CLIENT_ID}/default-client-scopes/${CLIENT_SCOPE}

# A User and group
export GROUP_ID=`./kcadm.sh create groups -r master -s name=ArgoCDAdmins -i`
export USER_ID=`./kcadm.sh create users -s username=argocduser -s enabled=true -r master -s totp=false -s emailVerified=false -s "requiredActions=[]" -i`
./kcadm.sh update users/${USER_ID}/groups/${GROUP_ID} -r master -s realm=master -s userId=${USER_ID} -s groupId=${GROUP_ID} -n

./kcadm.sh update users/${USER_ID}/reset-password -r master -s type=password -s value=argocduser -s temporary=false -n

echo -n `./kcadm.sh get clients/${CLIENT_ID}/client-secret --fields 'value' --format csv --noquotes` | base64

