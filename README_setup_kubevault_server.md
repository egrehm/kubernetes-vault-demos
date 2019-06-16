# Setup a vaultserver 

**expects to be executed from local term**

* uses etcd-operator to deploy backend
* uses kubevault-operator to deploy vaultserver

## Prepaire

You need some CLI binaries in your local path:

* Helm
* Vault
* kubectl



```
cd ./demo/ansible/
```

Set path to your KUBECONFIG in

* ./inventory/ansiblemaster.yml

Check kubevault vars:

* ./roles/kubevault/vars/main.yml

## Deploy

Given you have multiple cluster configs for your k8s cluster 'a','b','c' in
* ~/.kube/config.a
* ~/.kube/config.b
* ~/.kube/config.c

you can configure in ansiblemaster.yml:

 kubeconfigfile: /.kube/config.{{ project }}

and decide the cluster you want to deploy kubevault to with:

```
ansible-playbook ./cluster-svc.yml -i inventory/ansiblemaster.yml --extra-vars="project=a"
``` 

