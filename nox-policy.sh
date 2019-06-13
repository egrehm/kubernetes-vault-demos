#! /bin/bash
#set -x
export POLICY=${APP}-kv-ro
tee  > /tmp/${POLICY}.hcl << EOF
# For K/V v1 secrets engine
path "secret/$SECRETPATH/${APP}/*" {
    capabilities = ["read", "list"]
}
# For K/V v2 secrets engine
path "secret/$SECRETPATH/${APP}/*" {
    capabilities = ["read", "list"]
}
EOF

vault policy write ${POLICY} /tmp/${POLICY}.hcl
vault write auth/kubernetes/role/${ROLE} bound_service_account_names=${SVC_ACC} bound_service_account_namespaces=${APP} policies=${POLICY} ttl=24h


<<<<<<< HEAD
#POLICY=${APP}-kv-rw
#cat  > /tmp/${POLICY}.hcl << EOF
## For K/V v1 secrets engine
#path "secret/$SECRETPATH/${APP}/*" {
#    capabilities = ["create", "read", "update", "delete", "list"]
#}
## For K/V v2 secrets engine
#path "secret/$SECRETPATH/${APP}/*" {
#    capabilities = ["create", "read", "update", "delete", "list"]
#}
#EOF
#vault policy write ${POLICY} /tmp/${POLICY}.hcl
#vault write auth/kubernetes/role/${ROLE} bound_service_account_names=${SVC_ACC} bound_service_account_namespaces=${APP} policies=${POLICY} ttl=24h
#
#
#POLICY=${APP}-kv-ro-dev
#cat  > /tmp/${POLICY}.hcl << EOF
## For K/V v1 secrets engine
#path "secret/$SECRETPATH/${APP}/dev/*" {
#    capabilities = ["read", "list"]
#}
## For K/V v2 secrets engine
#path "secret/$SECRETPATH/${APP}/dev/*" {
#    capabilities = ["read", "list"]
#}
#EOF
#vault policy write ${POLICY} /tmp/${POLICY}.hcl
#vault write auth/kubernetes/role/${ROLE} bound_service_account_names=${SVC_ACC} bound_service_account_namespaces=${APP} policies=${POLICY} ttl=24h
#
#set +x
=======
POLICY=${APP}-kv-rw
cat  > /tmp/${POLICY}.hcl << EOF
# For K/V v1 secrets engine
path "secret/$SECRETPATH/${APP}/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
# For K/V v2 secrets engine
path "secret/$SECRETPATH/${APP}/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
vault policy write ${POLICY} /tmp/${POLICY}.hcl
vault write auth/kubernetes/role/${ROLE} bound_service_account_names=${SVC_ACC} bound_service_account_namespaces=${APP} policies=${POLICY} ttl=24h


POLICY=${APP}-kv-ro-dev
cat  > /tmp/${POLICY}.hcl << EOF
# For K/V v1 secrets engine
path "secret/$SECRETPATH/${APP}/dev/*" {
    capabilities = ["read", "list"]
}
# For K/V v2 secrets engine
path "secret/$SECRETPATH/${APP}/dev/*" {
    capabilities = ["read", "list"]
}
EOF
vault policy write ${POLICY} /tmp/${POLICY}.hcl
vault write auth/kubernetes/role/${ROLE} bound_service_account_names=${SVC_ACC} bound_service_account_namespaces=${APP} policies=${POLICY} ttl=24h

set +x
>>>>>>> 5362d3be5fe7a44fa2a2feb71eb25eb098662d7c

