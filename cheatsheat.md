# usefull cli smd and path


```
vault path-help secret
vault path-help secret/password
```

# from https://www.vaultproject.io/docs/commands/
```
echo -n '{"value":"itsasecret"}' | vault kv put secret/password -
echo -n "itsasecret" | vault kv put secret/password value=-

vault kv put secret/password @data.json
vault kv put secret/password value=@data.txt

vault kv get secret/password

vault read -field=password secret/build/registry/config 



```


