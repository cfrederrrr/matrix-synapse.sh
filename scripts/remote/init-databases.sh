#!/bin/bash -e

# Creates the synapse and keycloak databases and users on the DO managed PostgreSQL cluster.
# Run once as the ${APP_NAME} user on the droplet, before starting Synapse or Keycloak.
#
# Required environment variables:
#   POSTGRES_DB_HOST       - managed cluster hostname (from DO console)
#   DOADMIN_PASSWORD       - doadmin password (from DO console)
#   SYNAPSE_DB_PASSWORD    - password to set for the synapse user
#   KEYCLOAK_DB_PASSWORD   - password to set for the keycloak user

: "${POSTGRES_DB_HOST:?POSTGRES_DB_HOST must be set}"
: "${DOADMIN_PASSWORD:?DOADMIN_PASSWORD must be set}"
: "${SYNAPSE_DB_PASSWORD:?SYNAPSE_DB_PASSWORD must be set}"
: "${KEYCLOAK_DB_PASSWORD:?KEYCLOAK_DB_PASSWORD must be set}"

SCRIPT_DIR=$(dirname "$(realpath "$0")")

podman run --rm \
    -e PGPASSWORD="$DOADMIN_PASSWORD" \
    -v "$SCRIPT_DIR/init-databases.sql":/init.sql:ro,z \
    docker.io/library/postgres:16 \
    psql \
        "host=$POSTGRES_DB_HOST port=25060 dbname=defaultdb user=doadmin sslmode=require" \
        -v synapse_password="$SYNAPSE_DB_PASSWORD" \
        -v keycloak_password="$KEYCLOAK_DB_PASSWORD" \
        -f /init.sql
