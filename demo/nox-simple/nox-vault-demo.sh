#! /bin/bash
set -aeuo pipefail
#set -x
VAULTSERVER=https://vaultserver.vault.svc:8200
LOCALVAULTSERVER=https://127.0.0.1:8200  
f_init(){
kubectl get ns $NAMESPACE > /dev/null 2>&1 || kubectl create ns $NAMESPACE
}

f_create_sa(){
# Create a service account, '${SERVICEACCOUNT}'
if $(kubectl get -n $NAMESPACE serviceaccount ${SERVICEACCOUNT} > /dev/null 2>&1) ; then
  echo "${SERVICEACCOUNT} found in $NAMESPACE"
else
  kubectl create -n $NAMESPACE serviceaccount ${SERVICEACCOUNT}
  # tee /tmp/${SERVICEACCOUNT}-${NAMESPACE}-SA.yaml <<EOF
  echo "
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: $NAMESPACE 
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: $SERVICEACCOUNT
  namespace: $NAMESPACE " > /tmp/${SERVICEACCOUNT}-${NAMESPACE}-SA.yaml
  #EOF 
  # Update the '${SERVICEACCOUNT}' service account
  kubectl apply -n $NAMESPACE --filename /tmp/${SERVICEACCOUNT}-${NAMESPACE}-SA.yaml
fi
}


f_vault_write_random_secret(){
#SECRETPATH=$1
SECRETNAME=$APP
# create secret  and write to vault
echo "write a RANDOM secret to $SECRETPATH/${SECRETNAME}"
RANDOMSEC=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w16 | head -n1) || true # script has unreproducable error code '141'
vault  write ${SECRETPATH}/${SECRETNAME} value=${RANDOMSEC}
}

f_vault_gen_policy(){
#SECRETPATH=$1
POLICY=${APP}-${NAMESPACE}-${TYPE}
# create secret  and write to vault
envsubst < policy-${TYPE}-tmpl.hcl > /tmp/${POLICY}.hcl
vault policy write ${POLICY}  /tmp/${POLICY}.hcl
vault write auth/kubernetes/role/${VAULT_ROLE} bound_service_account_names=${SERVICEACCOUNT} bound_service_account_namespaces=${NAMESPACE} policies=${POLICY} ttl=24h
}

f_gen_demo_pod(){
if $(kubectl get po -n $NAMESPACE vault-demo-test > /dev/null 2>&1 ); then
  echo "delete existing pod"
  kubectl delete po -n $NAMESPACE vault-demo-test
  sleep 5
fi
sed -e "s/@@@NAMESPACE@@@/${NAMESPACE}/" \
    -e "s/@@@SERVICEACCOUNT@@@/${SERVICEACCOUNT}/" \
    -e "s#@@@REMOTE_VAULT_ADDR@@@#${REMOTE_VAULT_ADDR}#" \
    -e "s#@@@ROLE@@@#${VAULT_ROLE}#" \
    -e "s#@@@SECRETPATH@@@#${SECRETPATH}#" \
    -e "s#@@@APP@@@#${SECRETNAME}#g" \
    pod-demo-tmpl.yaml > /tmp/pod-${SERVICEACCOUNT}-${NAMESPACE}.yaml
kubectl apply -f /tmp/pod-${SERVICEACCOUNT}-${NAMESPACE}.yaml
}

f_usage(){
echo "

$0 -c -a <APP> -n <NAMESPACE> -p <PATH/TO/SECRET>

# Create 
-c create secret and policy
-a APP
-n NAMESPACE
-t Type of account [ro|rw]
-p PATH to secret i.e "secret/cluster/prod/team42"
example:
  $0 -c -a registry -n demo -p secret/for/demo -t ro

# Start Demo pod
-d demo
-n NAMESPACE 
-s SERVICEACCOUNT
-t Type of account [ro|rw]
-v REMOTE_VAULT_ADDR defaults to $VAULTSERVER
example:
  $0 -d -n demo -s demoaccount -t ro -r my-role -v $VAULTSERVER
     Read as: 
       create readonly demo account with name 'demoaccount' in namespace 'demo'

Vault kubernetes role will be \${SERVICEACCOUNT}_\${NAMESPACE}_\${TYPE}
ALL in one ( Create and demo):
 $0 -c -d -a registry -n demo -p secret/for/demo -t ro  -s demoaccount -t ro -r my-role -v $VAULTSERVER

"
}

# init vars for strict
CREATE= ; RUN_DEMO= ; SERVICEACCOUNT= ; NAMESPACE=

### GETOPTS
#set -x
while getopts ":a:p:n:s:v:t:r:cdh" opt; do
    case "$opt" in
        a) APP="$OPTARG";;
        p) SECRETPATH="$OPTARG";;
        n) NAMESPACE="$OPTARG";;
        s) SERVICEACCOUNT="$OPTARG";;
        t) TYPE="$OPTARG";; # just ro or rw are valid
        v) REMOTE_VAULT_ADDR="$OPTARG";;
        c) CREATE=True ;;
        d) RUN_DEMO=True ;;
        :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
        h) f_usage ;;
        *) f_usage ;;
    esac
done

### EXEC
if $(vault auth list > /dev/null 2>&1); then
  echo "Using vault from terminalenv"
else
  echo "You need to set vault env! QUIT!"
  exit 1
fi
TYPE=${TYPE:-ro} 
REMOTE_VAULT_ADDR=${REMOTE_VAULT_ADDR:-$VAULTSERVER}
VAULT_ROLE=${SERVICEACCOUNT}_${NAMESPACE}_${TYPE}
if [[ -n $NAMESPACE ]]; then
  f_init
fi
if [[ -n $SERVICEACCOUNT ]]; then
  f_create_sa
fi
if [[ $CREATE == True ]]; then
  APP=${APP:-config}
  f_vault_write_random_secret  
  f_vault_gen_policy
fi
if [[ $RUN_DEMO == True ]]; then
  echo "create pod in $NAMESPACE with sa: $SERVICEACCOUNT"
  f_gen_demo_pod  
  kubectl get po,sa -n $NAMESPACE
fi
