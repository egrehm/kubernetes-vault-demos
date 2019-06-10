# For K/V v1 secrets engine
path "secret/registry/*" {
    capabilities = ["read", "list"]
}

# For K/V v2 secrets engine
path "secret/data/registry/*" {
    capabilities = ["read", "list"]
}
