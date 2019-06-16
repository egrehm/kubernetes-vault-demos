# helm vault demos

## vault preparation


### PREP env
```
cd ./demo/helm
export APP=coolapp
export SECRETPATH=secret/cluster-prod/team-a/${APP}
export SECRETNAME=my-secret
export K8S_SERVICEACCOUNT=vault-sa
export K8S_NAMESPACE=demo
export TYPE=ro # apps should not need to write secret
export VAULT_ROLE=${K8S_SERVICEACCOUNT}_${K8S_NAMESPACE}_${TYPE}
export POLICY=${APP}_${K8S_NAMESPACE}_${TYPE}
export SERVICEACCOUNT=$K8S_SERVICEACCOUNT 
envsubst < ../nox-simple/policy-${TYPE}-tmpl.hcl > /tmp/${POLICY}.hcl
```

### create secret
```
RANDOMLEN=16
RANDOMSEC=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w${RANDOMLEN} | head -n1) || true 
vault write ${SECRETPATH}/${SECRETNAME} password=${RANDOMSEC} base64password=$(echo "${RANDOMSEC} "| base64)
```

### write policy and role
```
vault policy write  ${POLICY} /tmp/${POLICY}.hcl
vault write auth/kubernetes/role/${VAULT_ROLE} bound_service_account_names=${K8S_SERVICEACCOUNT} bound_service_account_namespaces=${K8S_NAMESPACE} policies=${POLICY} ttl=24h
```

### run your pod
expects the enviroment and workingdir from above (where this README is also)

```
helm upgrade    --install ${APP}-vault-demo --namespace ${K8S_NAMESPACE} --set "vault.serviceAccount=${K8S_SERVICEACCOUNT},vault.env.VAULT_SECRETPATH=${SECRETPATH},vault.env.VAULT_SECRETNAME=${SECRETNAME}"  ./vault-static-sidecar
```
