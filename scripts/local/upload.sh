#!/bin/bash -e

eval $(keepassxc-cli show -a homeserver ${APP_NAME}.kdbx script-variables)
set -x
rsync -av files ${APP_NAME}:.
rsync -av scripts/remote/ ${APP_NAME}:scripts
envsubst < templates/homeserver.yaml | ssh ${APP_NAME} 'cat > files/synapse/homeserver.yaml'
envsubst < templates/digitalocean.ini | ssh ${APP_NAME} 'cat > digitalocean.ini'
envsubst < templates/keycloak.env | ssh ${APP_NAME} 'cat > keycloak.env'
