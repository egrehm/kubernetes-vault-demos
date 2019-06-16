# Demos for vault on kubernetes

## all demos here **require**:

1. an existing kubernetes cluster to be configured with cluster-admin rights!
1. vaultserver running in same kubernetes cluster ( [ideally you would install a demo vaultserver](./README_setup_kubevault_server.md) )
1. a [configured vault cli](./README_cli.md) with required permissions


---

| WARNING: Does not run with multiple (active/standby) vaultservers! |
| --- |

 See [known issues](./README_issues.md)

---

## one-step demos
* [create_serviceaccount](./demo/nox-simple/README_sa.md)
* [simple demo](./demo/nox-simple/README_simple.md) - run a pod with a credentials from vault
* [readwrite demo](./demo/nox-simple/README_rw.md) - simulate a CI-CD service creating secrets and 3 teams restricted to their own team credentials
* [kubevault CRD](./demo/nox-simple/README_kubvault.md) - using kubevault CRDs

#### to be implemented
* helm demo ( one click purge)
* ansible demos
  * setup kubevault
  * setup SA
  * setup demos
* purge everything option




