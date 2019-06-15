# not ready!

added -k option as a quickstart

```
export NAMESPACE=kubevaultdemo
export SECRETPATH=secret/for/kubevault
export TYPE=ro # Options: [ro|rw]
export SERVICEACCOUNT=webaccount
export CREATE_SECRET=True

./nox-vault-demo.sh -c -k

```

TODO:
* tests 
* add demo pods 

