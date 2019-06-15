# kubevault

https://github.com/kubevault/docs/blob/master/docs/setup/operator/install.md

## Using kubectl for VaultServer
```console
# List all VaultServer objects
$ kubectl get vaultserver --all-namespaces

# List VaultServer objects for a namespace
$ kubectl get vaultserver -n <namespace>

# Get VaultServer YAML
$ kubectl get vaultserver -n <namespace> <name> -o yaml

# Describe VaultServer. Very useful to debug problems.
$ kubectl describe vaultserver -n <namespace> <name>
```

## Using kubectl for VaultPolicy
```console
# List all VaultPolicy objects
$ kubectl get vaultpolicy --all-namespaces

# List VaultPolicy objects for a namespace
$ kubectl get vaultpolicy -n <namespace>

# Get VaultPolicy YAML
$ kubectl get vaultpolicy -n <namespace> <name> -o yaml

# Describe VaultPolicy. Very useful to debug problems.
$ kubectl describe vaultpolicy -n <namespace> <name>
```

## Using kubectl for VaultPolicyBinding
```console
# List all VaultPolicyBinding objects
$ kubectl get vaultpolicybinding --all-namespaces

# List VaultPolicyBinding objects for a namespace
$ kubectl get vaultpolicybinding -n <namespace>

# Get VaultPolicyBinding YAML
$ kubectl get vaultpolicybinding -n <namespace> <name> -o yaml

# Describe VaultPolicyBinding. Very useful to debug problems.
$ kubectl describe vaultpolicybinding -n <namespace> <name>
```


## post helm install
```
kubectl get pods --all-namespaces -l app=vault-operator --watch

kubectl get crd -l app=vault

```
