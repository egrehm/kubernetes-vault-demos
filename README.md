# some demos for vault on kubernetes

all demos here *require an existing kubernetes cluster* be configured with cluster-admin rights!


## create demo app against running vaultserver

*requires a configured vault cli* in the executing terminal (see set Vault enviroment)!

### tl;dr
one step demo
```
cd ./demo/nox-simple
./nox-vault-demo.sh -c -d -a webapp -n demo -p secret/for/demo -t ro  -s webaccount -t ro -r my-role
while ! $(kubectl get po -n demo | grep -q Running ); do echo "waiting for:  $(kubectl get po -n demo --no-headers)"; sleep 2; done
kubectl exec -it -n demo webapp -c nginx -- cat /etc/app/webapp /etc/app/webapp.plainpass;echo
```

Read as:
1. create namespace demo if not existing
1. serviceaccount with name 'webaccount' in namespace 'demo'
1. create random secret in secret/for/demo/webapp
1. create clusterrolebinding 'webaccount-demo-tokenreview-binding'
1. create vault ro policy for 'secret/for/demo/\*'
1. create vault role in 'auth/kubernetes/role/webaccount\_demo\_ro'
1. start pod 'webapp' in namespace 'demo' with serviceaccount 'webaccount'
  1. use service account token to get vault_token
  1. use vault token to get pass and write it to '/etc/app/webapp'







### set Vault enviroment
you might use (after editing to match your env):

```
# forward vaultserver to localhost and set required env
source <(./set-vaul-cli.sh)
# test access
vault auth list
```


