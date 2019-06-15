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
fi

# always apply to assure lastest config
echo "
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: ${VAULT_ROLE}-tokenreview-binding
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
}


f_vault_write_random_secret(){
#SECRETPATH=$1
# create secret  and write to vault
echo "write a RANDOM secret to $SECRETPATH/${SECRETNAME}"
RANDOMSEC=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w16 | head -n1) || true # script has unreproducable error code '141'
vault  write ${SECRETPATH}/${SECRETNAME} value=${RANDOMSEC}
}

f_vault_gen_policy(){
#SECRETPATH=$1
# create secret  and write to vault
envsubst < policy-${TYPE}-tmpl.hcl > /tmp/${POLICY}.hcl
vault policy write ${POLICY}  /tmp/${POLICY}.hcl
vault write auth/kubernetes/role/${VAULT_ROLE} bound_service_account_names=${SERVICEACCOUNT} bound_service_account_namespaces=${NAMESPACE} policies=${POLICY} ttl=24h
}

f_del_demo_pod(){
if $(kubectl get po -n $NAMESPACE $APP > /dev/null 2>&1 ); then
  echo "delete existing pod"
  kubectl delete po -n $NAMESPACE $APP --force --grace-period=0 > /dev/null 2>&1 &
fi
}

f_gen_demo_pod(){
TEMPLATE=${TEMPLATE:-pod-demo-tmpl.yaml}
while $(kubectl get po -n $NAMESPACE $APP > /dev/null 2>&1 ); do
  echo "still deleting existing pod:   $(kubectl get po -n $NAMESPACE $APP --no-headers )"
  sleep 2
done

sed -e "s/@@@NAMESPACE@@@/${NAMESPACE}/g" \
    -e "s/@@@SERVICEACCOUNT@@@/${SERVICEACCOUNT}/g" \
    -e "s#@@@REMOTE_VAULT_ADDR@@@#${REMOTE_VAULT_ADDR}#g" \
    -e "s#@@@ROLE@@@#${VAULT_ROLE}#g" \
    -e "s#@@@SECRETPATH@@@#${SECRETPATH}#g" \
    -e "s#@@@APP@@@#${SECRETNAME}#g" \
    $TEMPLATE > /tmp/${SERVICEACCOUNT}-${NAMESPACE}-$TEMPLATE.yaml
echo "DEBUG: kubectl apply -f /tmp/${SERVICEACCOUNT}-${NAMESPACE}-$TEMPLATE.yaml"
kubectl apply -f /tmp/${SERVICEACCOUNT}-${NAMESPACE}-$TEMPLATE.yaml
}

f_gen_rw_demo_pods(){
set -x
NAMESPACE_SAVE=$NAMESPACE
SERVICEACCOUNT_SAVE=$SERVICEACCOUNT
# gen ci-cd demo sa, pod, policy and roles
NAMESPACE=demo
SERVICEACCOUNT=ci-cd-sec-creator
TYPE=rw
SECRETPATH=secret/infra/ci_cd_created
TEMPLATE=pod-rw-demo-tmpl.yaml
APP=ci-cd
# redefine
VAULT_ROLE=${SERVICEACCOUNT}_${NAMESPACE}_${TYPE}
POLICY=${APP}-${NAMESPACE}-${TYPE}
f_init
f_create_sa
f_vault_gen_policy
f_gen_demo_pod  

# gen clients  ci-cd demo sa, pod, policy and roles
for TEAM in team-a team-b team-c; do
  TYPO=ro
  APP=ro-client-app
  NAMESPACE=$TEAM
  SERVICEACCOUNT=${TEAM}-registry
  TEMPLATE=pod-rw-client-demo-tmpl.yaml
  SECRETPATH=secret/infra/ci_cd_created/$TEAM
  # redefine
  VAULT_ROLE=${SERVICEACCOUNT}_${NAMESPACE}_${TYPE}
  POLICY=${APP}-${NAMESPACE}-${TYPE}
  f_init
  f_create_sa
  f_vault_gen_policy
  f_gen_demo_pod  
done
NAMESPACE=$NAMESPACE_SAVE
SERVICEACCOUNT=$SERVICEACCOUNT_SAVE
}

f_usage(){
echo "

$0 -c -a <APP> -n <NAMESPACE> -p <PATH/TO/SECRET>

# Create 
-c create policy and binding
  -a APP
  -n NAMESPACE
  -t Type of account [ro|rw]
  -p PATH to secret i.e "secret/cluster/prod/team42"
  -S create new secret
example:
  $0 -c -a registry -n demo -p secret/for/demo -t ro

# Start Demo pod
-d demo
  -n NAMESPACE 
  -s SERVICEACCOUNT
  -t Type of account [ro|rw]
  -v REMOTE_VAULT_ADDR defaults to $VAULTSERVER
example:
  $0 -d -n demo -s demoaccount -t ro -v $VAULTSERVER
     Read as: 
       create readonly demo account with name 'demoaccount' in namespace 'demo'

# Gather Facts:
-g 

# create secret
-S

ALL in one ( Create, demo, gather_facts):
 $0 -c -d -g -a registry -n demo -p secret/for/demo -t ro  -s demoaccount -t ro  -v $VAULTSERVER -S

"
exit 1
}

f_gather_facts(){
echo "### start gathering facts (-g)  ###"
while ! $(kubectl get po -n ${NAMESPACE} | grep -q '2/2.*Running' ); do     
  echo "waiting for:  $(kubectl get po -n ${NAMESPACE} --no-headers)"
  sleep 2              
done                   
sleep 2
echo "########################################################################################"
echo "Created vault auth/kubernetes/role"
echo "########################################################################################"
vault read auth/kubernetes/role/${VAULT_ROLE}
echo "########################################################################################"
echo "Created vault policy ${POLICY}"
echo "########################################################################################"
vault policy read ${POLICY}
echo "########################################################################################"
echo "k8s serviceaccount in 'demo':"
echo "########################################################################################"
kubectl get sa -n ${NAMESPACE} $SERVICEACCOUNT
echo "########################################################################################"
echo "created clusterrolebinding:"
echo "########################################################################################"
kubectl get clusterrolebinding ${VAULT_ROLE}-tokenreview-binding 
echo "########################################################################################"
echo "Created secret from vaultserver  'secret/for/demo/${APP}':"
echo "########################################################################################"
vault read ${SECRETPATH}/${APP}
echo "########################################################################################"
echo "Here is your vault password delivered into your container!"
echo "Created passobjects from container ( cat /etc/app/${APP} /etc/app/${APP}.full):"  
echo "########################################################################################"
kubectl exec -it -n ${NAMESPACE} ${APP} -c curl -- cat /etc/app/${APP}.full /etc/app/${APP}
echo
echo "########################################################################################"
}


# init vars for strict
CREATE= ; RUN_DEMO= ; SERVICEACCOUNT=${SERVICEACCOUNT:-} ; NAMESPACE=${NAMESPACE:-}

### GETOPTS
#set -x
while getopts ":a:p:n:s:v:t:rgcdhS" opt; do
    case "$opt" in
        a) APP="$OPTARG";;
        p) SECRETPATH="$OPTARG";;
        n) NAMESPACE="$OPTARG";;
        s) SERVICEACCOUNT="$OPTARG";;
        t) TYPE="$OPTARG";; # just ro or rw are valid
        r) RW_DEMO=True ;;
        v) REMOTE_VAULT_ADDR="$OPTARG";;
        g) GATHER_FACTS=True;;
        c) CREATE=True ;;
        d) RUN_DEMO=True ;;
        S) CREATE_SECRET=True ;;
        :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
        h) f_usage ;;
        #*) f_usage ;;
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
POLICY=${APP}-${NAMESPACE}-${TYPE}
SECRETNAME=$APP
if [[ $RW_DEMO == True ]]; then
  echo "create pods for read-write"
  f_gen_rw_demo_pods  
fi
if [[ -n $NAMESPACE ]]; then
  f_init
fi
if [[ -n $SERVICEACCOUNT ]]; then
  f_create_sa
fi
if [[ $RUN_DEMO == True ]]; then
  # del first to save a bit time
  f_del_demo_pod  
fi
if [[ ${CREATE_SECRET:-False} == True ]]; then
  f_vault_write_random_secret
fi  
if [[ $CREATE == True ]]; then
  APP=${APP:-config}
  f_vault_gen_policy
fi
if [[ $RUN_DEMO == True ]]; then
  echo "create pod in $NAMESPACE with sa: $SERVICEACCOUNT"
  f_gen_demo_pod  
fi
if [[ ${GATHER_FACTS:-False} == True ]]; then
  f_gather_facts
fi 
