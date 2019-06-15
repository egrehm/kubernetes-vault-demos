# simple demo

all demos here require:
 * an existing kubernetes cluster be configured with cluster-admin rights!
 * a runningvault server
 * a configured vault-cli matching permissions


## create demo 

*requires a configured vault cli* in the executing terminal (see set Vault enviroment)!

### tl;dr
one step demo getopts way
```
cd ./demo/nox-simple
./nox-vault-demo.sh -c -d -g -a webapp -n demo -p secret/for/demo -t ro  -s webaccount -t ro -S 
```
... or if you prefer to define variables yourself this is fine too
```
export APP=webapp
export NAMESPACE=demo
export SECRETPATH=secret/for/demo
export TYPE=ro
export SERVICEACCOUNT=webaccount
export CREATE_SECRET=True
./nox-vault-demo.sh -c -d -g
```

Read as:
1. create namespace demo if not existing
1. create serviceaccount with name 'webaccount' in namespace 'demo'
1. Option '-c' create:
  1. create random secret in secret/for/demo/webapp
  1. create clusterrolebinding 'webaccount-demo-tokenreview-binding'
  1. create vault ro policy for 'secret/for/demo/\*'
  1. create vault role in 'auth/kubernetes/role/webaccount\_demo\_ro'
1. Option '-d' deploy:
  1. start pod 'webapp' in namespace 'demo' with serviceaccount 'webaccount'
  1. start vault initContainer
    1. use service account token to get vault_token
    1. use vault token to get pass and write it to '/etc/app/webapp'
  1. start your app with '/etc/app volumemount' and find '/etc/app/webapp'
1. Option '-g' gather facts:
  1. gather demo facts






### set Vault enviroment
you might use (after editing to match your env):

```
# forward vaultserver to localhost and set required env
source <(./set-vaul-cli.sh)
# test access
vault auth list
```


