# simple demo

## tl;dr
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

cd ./demo/nox-simple
./nox-vault-demo.sh -c -d -g
export CREATE_SECRET=False   # You neeed to cleanup yourself this way
```

## executed steps:

### 1. prep
1. create namespace demo if not existing
1. create serviceaccount with name 'webaccount' in namespace 'demo'

### 2. [create serviceaccount](./README_sa.md) - Option: -c

### 3. deploy steps - Option: -d
  1. start pod 'webapp' in namespace 'demo' with serviceaccount 'webaccount'
  1. start vault initContainer
    1. use service account token to get vault_token
    1. use vault token to get pass and write it to '/etc/app/webapp'
  1. start your app with '/etc/app volumemount' and find '/etc/app/webapp'

### 4. gather facts - Option: -g
  1. do -g  get facts

---

the options are independent as far as Variables are provided und kubapi accepts the change :)
```
./nox-vault-demo.sh -c
./nox-vault-demo.sh -d
./nox-vault-demo.sh -g
```

