#! /bin/bash
set -aeuo pipefail
#set -x

vault secrets enable database
    #requires_ssl connection_url="postgresql://{{username}}:{{password}}@gitea-postgres-homeclan-de-postgresql.git.svc.cluster.local:5432/" \

vault write database/config/postgres-git \
    plugin_name=postgresql-database-plugin \
    allowed_roles="postgres-role-git" \
    connection_url="postgresql://{{username}}:{{password}}@gitea-postgres-homeclan-de-postgresql.git.svc.cluster.local:5432/?sslmode=disable" \
    username="postgres" \
    password="ukp0SCFE5N"

vault write database/roles/postgres-role-git \
    db_name=postgres-git \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

f_usage(){
echo "usage: $0"
}

while getopts ":p:s:i:hno" opt; do
    case "$opt" in
        p) PROJECT="$OPTARG";;
        s) SVC="$OPTARG"; IS_SVC=true ;; 
        i) extIP="$OPTARG";;
        n) TOGGLE=True ;; # no OPTARG no ":" 
        o) TOGGLE=True ;;  
        :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
        h) f_usage ;;
        *) f_usage ;;
    esac 
done

