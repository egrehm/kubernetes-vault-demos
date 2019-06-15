# some demos for vault on kubernetes

all demos here **require**:

* an existing kubernetes cluster to be configured with cluster-admin rights!
* vaultserver running in kubernetes (adapting to use external vaultserver should not be too hard)

| WARNING: Does not run with multiple (active/standby) vaultservers! |
| --- |

... due to 'permission denied' issues wenn k8s-svc selects non active vaultservers (to be fixed)
**Make sure replicas is set to 1** 

```
kubectl edit deployment -n vault vaultserver
```

## one-step demos
* [create_serviceaccount](./demo/nox-simple/README_sa.md)
* [simple demo](./demo/nox-simple/README_simple.md) - run a pod with a credentials from vault
* [readwrite demo](./demo/nox-simple/README_rw.md) - simulate a CI-CD service creating secrets and 3 teams restricted to their own team credentials
* [kubevault CRD](./demo/nox-simple/README_kubvault.md) - using kubevault CRDs

## to be implemented
* helm demo ( one click purge)


### set Vault enviroment
you might use (after editing to match your env):

```
# forward vaultserver to localhost and set required env
source <(./set-vaul-cli.sh)
# test access
vault auth list
```


