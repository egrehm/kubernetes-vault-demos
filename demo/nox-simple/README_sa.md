# Create a serviceaccount with vault role and policy

```
export APP=webapp
export NAMESPACE=demo
export SECRETPATH=secret/for/demo
export TYPE=ro # Options: [ro|rw]
export SERVICEACCOUNT=webaccount
# if you want a random secret to generated: export CREATE_SECRET=True

./nox-vault-demo.sh -c 
```
or same with getops
```
./nox-vault-demo.sh -c -a webapp -n demo -p secret/for/demo -t ro -s webaccount
```

## executed steps:

### prep
1. create namespace demo if not existing
1. create serviceaccount with name 'webaccount' in namespace 'demo'
### create
1. random secret in secret/for/demo/webapp if "CREATE_SECRET=True"
1. create clusterrolebinding 'webaccount-demo-tokenreview-binding'
1. create vault ro|rw policy for 'secret/for/demo/\*'
1. create vault role in 'auth/kubernetes/role/webaccount\_demo\_ro'

