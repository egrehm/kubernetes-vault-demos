# some demos for vault on kubernetes

all demos here *require an existing kubernetes cluster* be configured with cluster-admin rights!



## one-step demos
[simple demo](./demo/nox-simple/README_simple.md) - run a pod with a credentials from vault
[readwrite demo](./demo/nox-simple/README_rw.md) - simulate a CI-CD service creating secrets and 3 teams restricted to their own team credentials






### set Vault enviroment
you might use (after editing to match your env):

```
# forward vaultserver to localhost and set required env
source <(./set-vaul-cli.sh)
# test access
vault auth list
```


