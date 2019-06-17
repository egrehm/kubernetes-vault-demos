# Simulate a CI-CD service creating secrets and 3 teams restricted to their own team credentials

### tl;dr
```
cd ./demo/nox-simple/
./nox-vault-demo.sh -r
```

### validate
```
for LOG in team-a team-b team-c buildsimulator ;do 
  kubectl logs -n $LOG webapp curl
done
```

#### creates Namespaces SA Policy Binding
* buildsimulator -  RW access to  secret/infra/ci\_cd\_created/\*
* team-a         -  RO access to  secret/infra/ci\_cd\_created/team-a/\*
* team-b         -  RO access to  secret/infra/ci\_cd\_created/team-b/\*
* team-c         -  RO access to  secret/infra/ci\_cd\_created/team-c/\*

