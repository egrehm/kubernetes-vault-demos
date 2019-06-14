# For K/V v1 secrets engine
path "${SECRETPATH}/*" {
    capabilities = ["read", "list"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
