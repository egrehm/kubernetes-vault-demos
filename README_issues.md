# known issues

## permission denied when requesting token

... due to 'permission denied' issues if k8s-svc selects non active vaultservers (to be fixed)

**Make sure replicas is set to 1** 

for example:
```
kubectl edit deployment -n vault vaultserver
```

