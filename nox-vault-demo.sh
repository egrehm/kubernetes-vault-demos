#! /bin/bash
set -aeuo pipefail
#set -x
#APP=${APP:-registry}
#SVC_ACC=vault-${APP}
#ROLE=${APP}-role
#NAMESPACE=$APP
#SECRETPATH=${SECRETPATH:-}
VAULTSERVER=https://vaultserver.vault.svc:8200
f_init(){
kubectl get ns $NAMESPACE > /dev/null 2>&1 || kubectl create ns $NAMESPACE
}

f_create_sa(){
# Create a service account, '${SVC_ACC}'
kubectl get -n $NAMESPACE serviceaccount ${SVC_ACC} > /dev/null 2>&1 || kubectl create -n $NAMESPACE serviceaccount ${SVC_ACC}



# tee /tmp/${SVC_ACC}-${NAMESPACE}-SA.yaml <<EOF
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
  name: $SVC_ACC
  namespace: $NAMESPACE
" > /tmp/${SVC_ACC}-${NAMESPACE}-SA.yaml
#EOF 



# Update the '${SVC_ACC}' service account
kubectl apply -n $NAMESPACE --filename /tmp/${SVC_ACC}-${NAMESPACE}-SA.yaml
}

f_gen_pods(){

envsubst < pod.yaml > /tmp/pod-${APP}.yaml
kubectl apply -n $NAMESPACE --filename /tmp/pod-${APP}.yaml

#echo "
#kind: Pod
#apiVersion: v1
#metadata:
#  name: vault-${APP}-test
#spec:
#  serviceAccountName: vault-${APP}
#  initContainers:
#    - name: vault-init
#      image: everpeace/curl-jq
#      command:
#        - \"sh\"
#        - \"-c\"
#        - >
#          KUBE_TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token);
#          curl --request POST --data '{\"jwt\": \"\$KUBE_TOKEN\", \"role\": \"$SVC_ACC\"}' ${VAULTSERVER}/v1/auth/kubernetes/login | jq -j '.auth.client_token' > /etc/vault/token;
#          X_VAULT_TOKEN=\$(cat /etc/vault/token);
#          curl --header \"X-Vault-Token: \$X_VAULT_TOKEN\" ${VAULTSERVER}/v1/secret/$SECRETPATH/${APP}/registry > /etc/app/registry;
#      volumeMounts:
#        - name: app-creds
#          mountPath: /etc/app
#        - name: vault-token
#          mountPath: /etc/vault
#  containers:
#  - image: vault
#    name: vault
#    command:
#      - \"cat\"
#    volumeMounts:
#    - mountPath: /var/run/secrets/tokens
#      name: vault-token
#    - name: app-creds
#      mountPath: /etc/app
#  serviceAccountName: vault-${APP}
#  volumes:
#  - name: vault-token
#    emptyDir: {}
#    #alt_way projected:
#    #alt_way   sources:
#    #alt_way   - serviceAccountToken:
#    #alt_way       path: vault-token
#    #alt_way       expirationSeconds: 7200
#    #alt_way       audience: vault
#  - name: app-creds
#    emptyDir: {}
#" | kubectl apply -n $APP -f- 


}

f_vault_write_secret(){
SECRETPATH=$1
SECRETNAME=$APP
# create secret  and write to vault
RANDOMSEC=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w16 | head -n1)
vault  write ${SECRETPATH}/${SECRETNAME} value=${RANDOMSEC}
}

f_vault_gen_policy(){
SECRETPATH=$1
POLICY=${APP}-${NAMESPACE}-${TYPE}
# create secret  and write to vault
envsubst < policy-${TYPE}-tmpl.hcl > /tmp/${POLICY}.hcl

}

f_usage(){
echo "

$0 -c -a <APP> -n <NAMESPACE> -p <PATH/TO/SECRET>

-c create secret and policy
-a APP
-n NAMESPACE
-p PATH to secret i.e "secret/cluster/prod/team42"

example:
$0 -c -a registry -n demo -p secret/for/demo

"
}

while getopts ":a:p:n:h" opt; do
    case "$opt" in
        a) APP="$OPTARG";;
        p) PATH="$OPTARG"; IS_SVC=true ;;
        n) NAMESPACE="$OPTARG";;
        :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
        h) f_usage ;;
        *) f_usage ;;
    esac
done

echo " needs finish"
exit 1

for APP in red green blue; do  
  SVC_ACC=vault-${APP}
  ROLE=${APP}-role
  NAMESPACE=$APP
  SECRETPATH=cluster/demo
  f_init
  f_create_sa
  vault write secret/$SECRETPATH/${APP}/registry value=$APP 
  vault write secret/$SECRETPATH/${APP}/dev/registry value=${APP}-dev 
  #./k8s-demo/setup-k8s-auth.sh 
  #f_gen_policy
  ./nox-policy.sh
  f_gen_pods
  
done


