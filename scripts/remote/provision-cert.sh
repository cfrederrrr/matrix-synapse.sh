#!/bin/bash -x

EMAIL=$1
: "${EMAIL:?Usage: ./scripts/provision-certs EMAIL DOMAIN}"

DOMAIN=$2
: "${DOMAIN:?Usage: ./scripts/provision-certs EMAIL DOMAIN}"

podman run --rm \
    -v letsencrypt:/etc/letsencrypt \
    -v /var/local/${APP_NAME}/digitalocean.ini:/credentials/digitalocean.ini:ro,z \
    docker.io/certbot/dns-digitalocean certonly \
        --dns-digitalocean \
        --dns-digitalocean-credentials /credentials/digitalocean.ini \
        --agree-tos \
        --non-interactive \
        --email "$EMAIL" \
        -d $DOMAIN -d auth.$DOMAIN -d matrix.$DOMAIN

