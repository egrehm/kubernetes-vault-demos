# For K/V v1 secrets engine
path "${SECRETPATH}/*" {
    capabilities = ["read", "list"]
}
