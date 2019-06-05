#! /bin/bash
set -aeuo pipefail
# set -x 
NAMESPACE=vault
VAULTSERVER=
CRT_FILE=/tmp/ca-vault.crt

f_enable_proxy(){
ACTIVE_VAULT=$(kubectl -n $NAMESPACE get vault -o yaml | grep  -i active | cut -d : -f 2)
#echo " RUN: kubectl -n $NAMESPACE port-forward $ACTIVE_VAULT 8200 > /tmp/kube-proxy8200 2>&1 &"
PF_PS=$(ps aux | grep  "kubectl.*8200" | grep  -v grep; true)
if [[ -n $PF_PS ]];then
  PF_PID=$(echo $PF_PS |  awk '{ print $2 }')
  #echo "killing port-forward to vault"
  kill -9 $PF_PID > /dev/null 2>&1
fi
echo "# Running proxy. Logging to /tmp/kube-proxy8200"
kubectl -n $NAMESPACE port-forward $ACTIVE_VAULT 8200 > /tmp/kube-proxy8200 2>&1 &
# kubectl -n vault get vault example -o jsonpath='{.status.vaultStatus.active}' | xargs -0 -I {} kubectl -n default port-forward {} 8200
}

f_set_env(){

kubectl get secrets -n $NAMESPACE vaultserver-vault-tls -o  jsonpath='{.data.tls\.crt}' | base64 -d > $CRT_FILE
echo "
# You need to set env:
######
export VAULT_SKIP_VERIFY="true"
export VAULT_ADDR='https://127.0.0.1:8200'
export VAULT_TOKEN=$(kubectl get secrets -n vault vault-keys -o jsonpath='{.data.vault-root-token}' | base64 -d)
export VAULT_CACERT=$CRT_FILE
######
"
}

f_usage(){
echo "usage: $0"
}

f_enable_proxy
f_set_env
