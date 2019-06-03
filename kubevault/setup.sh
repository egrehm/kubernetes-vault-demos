#! /bin/bash

# Use Ansible for now !!!!!

exit 0



set -aeuo pipefail
set -x 

PROJECT=$1
NAMESPACE=vault
SERV_ACC=default
f_usage(){
echo "usage: $0"
}


cd ~/git/hub/vault-operator/example
git pull
sed -e "s/<namespace>/${NAMESPACE}/g"   -e "s/<service-account>/${SERV_ACC}/g"  rbac-template.yaml > rbac.yaml
kubectl get ns $NAMESPACE > /dev/null ||kubectl create namespace $NAMESPACE
kubectl apply -n $NAMESPACE  -f rbac.yaml
## # etcd  operator from coreos
# kubectl create -f etcd_crds.yaml
# kubectl -n $NAMSPACE create -f etcd-operator-deploy.yaml
cd -

cd ~/git/y/ansible-playground/playbooks/
ansible-playbook cluster-svc.yml -i inventory/cluster-full-init.yml --extra-vars="service=kubevault project=$PROJECT"
cd -

kubectl apply -f ~/git/y/vault/kubevault/VaultServer_existingetcd.yaml


 

