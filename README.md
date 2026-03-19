# matrix
this is how i deployed matrix.

## technologies used
+ digitalocean
+ rocky linux 9
+ keepassxc & keepassxc-cli
+ bash
+ podman
+ sql kind of

## assumptions
+ i already owned the domain and delegated it to digitalocean, so this assumes you have that already
+ you already have an droplet up and running. i've also included some initial stuff including some security configurations in a script that i recommend you use but it's up to you. not really required for this deployment
+ you already have a postgres version 16+ database including the url and credentials
+ you already have a keepass database with all the required environment variables set as an attribute on a secret called 'shell-variables'
+ you already have a DOCN spaces bucket or some other s3 bucket and the associated key

## secrets
these should be pretty self explanatory. a few of them are provided by digitalocean and the most of the rest are are just random long strings generated with
```py
import secrets
secrets.token_urlsafe(32)
```

+ APP_NAME - whatever you want, as long as it's 1 word alphanumeric with no hyphens or underscores
+ SERVER_NAME - a domain you own, e.g. server.com that has been delegated to digitalocean
+ POSTGRES_DB_HOST
+ DOCN_API_TOKEN
+ KEYCLOAK_ADMIN_PASSWORD
+ KEYCLOAK_DB_PASSWORD
+ SPACES_ACCESS_KEY
+ SPACES_SECRET_KEY
+ SYNAPSE_DB_PASSWORD
+ SYNAPSE_FORM_SECRET
+ SYNAPSE_MACAROON_SECRET
+ SYNAPSE_OIDC_SECRET - this one is actually special. you get this one from keycloak after creating the client for synapse and before starting synapse for the first time
+ SYNAPSE_REGISTRATION_SECRET

## how to use
1. download the repo (button up top)
1. comment the synapse server out of `files/nginx/nginx.conf` but do not delete it because we'll need it later
1. make sure `${APP_NAME}` is in your `~/.ssh/config` as the hostname of your droplet
1. run `./scripts/local/upload.sh`
1. ssh to the host and run
    ```sh
    ./scripts/install-synapse.sh
    ./scripts/remote/init-databases.sql
    # for your domain, if you don't already have a certificate
    ./scripts/remote/provision-cert.sh your@email.com matrix.<your domain here> auth.<your domain here>
    ```
1. run `systemctl start keycloak nginx`
1. go to keycloak (`https://auth.<your domain here>/`) and create the realm and client. you'll have to look up how to do this if you don't already know because it's multiple steps and it's documented in many places elsewhere so i'm not going to lay out the steps here.
    1. i will say this though - the settings you need on the realm are these and only these
        + the id has to match whatever you put in the `homeserver.yaml` file when you renamed everything
        + valid redirect URIs must be: `https://matrix.<your domain here>/_synapse/client/oidc/callback`
        + web origins must be: `https://matrix.<your domain here>`
        + check "Standard flow" in the "Authentication flows" section
1. still in keycloak, go to "credentials" (third tab) and generate a client secret. add that to keepass as an environment variable like mentioned above
1. log out of the ssh session
1. uncomment the synapse block you commented earlier
1. run `./scripts/local/upload.sh` again to add the OIDC secret to your homeserver.yaml file, or just paste it in yourself (i recommend using the script so you don't forget to populate the variable in keepass and break future deployments)
1. ssh back into the droplet
1. run `./scripts/install-synapse.sh` or run all of the following:
    ```sh
    SYNAPSE_DATA=$(podman volume mount synapse-data)
    cp /var/local/${APP_NAME}/files/synapse/homeserver.yaml $SYNAPSE_DATA
    cp /var/local/${APP_NAME}/files/synapse/log.config $SYNAPSE_DATA
    chown -R 991:991 $SYNAPSE_DATA # for some reason matrix runs as an unprivileged user with this uid:gid
    podman volume unmount synapse-data
    ```
1. run `systemctl start synapse`
1. run `systemctl restart nginx`
1. use keycloak to create users as needed
