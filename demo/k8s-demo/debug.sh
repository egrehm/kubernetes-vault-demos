
VAULT_ADDR=https://vaultserver.vault.svc:8200
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
apk update && apk add curl jq
#curl -sk $VAULT_ADDR/v1/sys/health  | jq
VAULT_TOKEN=$(curl -sk --request POST  --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "vault-nox-demovault"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token')
curl -sk  --header "X-Vault-Token: $VAULT_TOKEN" --request GET $VAULT_ADDR/v1/secret/demovault/foo/config
curl -sk  --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"bar": "baz"}' $VAULT_ADDR/v1/secret/demovault/foo/testconfig
