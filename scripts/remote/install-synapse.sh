#!/bin/bash -xe

CERTBOT_EMAIL=$1

if ! podman volume exists letsencrypt
then podman volume create letsencrypt
fi

if ! podman volume exists synapse-data
then podman volume create synapse-data
fi

if ! podman network exists ${APP_NAME}
then podman network create ${APP_NAME}
fi

cp files/systemd/*.container /etc/containers/systemd/
cp files/systemd/*.timer /etc/systemd/system

podman build -t localhost/synapse-s3:latest /var/local/${APP_NAME}/files/synapse/
systemctl daemon-reload

SYNAPSE_DATA=$(podman volume mount synapse-data)
cp /var/local/${APP_NAME}/files/synapse/homeserver.yaml $SYNAPSE_DATA
cp /var/local/${APP_NAME}/files/synapse/log.config $SYNAPSE_DATA
chown -R 991:991 $SYNAPSE_DATA
podman volume unmount synapse-data

firewall-cmd --permanent --zone=public --add-service=http,https
firewall-cmd --permanent --zone=public --add-interface=$(podman network inspect ${APP_NAME} | jq .[0].network_interface)
firewall-cmd --reload
