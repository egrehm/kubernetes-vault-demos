# 

# tl;dr
```
cd ./demo/nox-simple/
./nox-vault-demo.sh -r
```

# validate
```
for LOG in team-a team-b team-c demo ;do 
  kubectl logs -n $LOG webapp curl
done
```
