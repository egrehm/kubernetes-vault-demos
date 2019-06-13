# For K/V v1 secrets engine
path "${SECRETPATH}/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
