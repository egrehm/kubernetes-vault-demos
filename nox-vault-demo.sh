#! /bin/bash

#set -x
#APP=${APP:-registry}
SVC_ACC=vault-${APP}
ROLE=${APP}-role
NAMESPACE=$APP
SECRETPATH=${SECRETPATH:-}
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

echo "
kind: Pod
apiVersion: v1
metadata:
  name: nginx
spec:
  serviceAccountName: vault-${APP}
  initContainers:
    - name: vault-init
      image: everpeace/curl-jq
      command:
        - "sh"
        - "-c"
        - >
          KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token);
          curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "postgres"}' http://errant-mandrill-vault:8200/v1/auth/kubernetes/login | jq -j '.auth.client_token' > /etc/vault/token;
          X_VAULT_TOKEN=$(cat /etc/vault/token);
          curl --header "X-Vault-Token: $X_VAULT_TOKEN" http://errant-mandrill-vault:8200/v1/database/creds/postgres-role > /etc/app/creds.json;
      volumeMounts:
        - name: app-creds
          mountPath: /etc/app
        - name: vault-token
          mountPath: /etc/vault
  containers:
  - image: vault
    name: vault
    command:
      - "cat"
    volumeMounts:
    - mountPath: /var/run/secrets/tokens
      name: vault-token
  serviceAccountName: vault-${APP}
  volumes:
  - name: vault-token
    projected:
      sources:
      - serviceAccountToken:
          path: vault-token
          expirationSeconds: 7200
          audience: vault
" | kubectl apply -n $APP -f- 


}


f_gen_policy(){
f_gen_ro_policy
f_gen_rw_policy
f_gen_ro_dev_policy
}

for APP in red green blue; do  
  SVC_ACC=vault-${APP}
  ROLE=${APP}-role
  NAMESPACE=$APP
  SECRETPATH=${SECRETPATH:-}
  export SECRETPATH=cluster/demo
  f_init
  f_create_sa
  vault write secret/$SECRETPATH/${APP}/registry value=$APP 
  vault write secret/$SECRETPATH/${APP}/dev/registry value=${APP}-dev 
  #./k8s-demo/setup-k8s-auth.sh 
  #f_gen_policy
  ./nox-policy.sh
  f_gen_pods
  
done


