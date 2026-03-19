-- Run via init-databases.sh, which passes synapse_password and keycloak_password
-- as psql variables. The :'var' syntax quotes them as string literals.

-- Synapse
CREATE DATABASE synapse
    ENCODING 'UTF8'
    LC_COLLATE='C'
    LC_CTYPE='C'
    TEMPLATE template0;

CREATE USER synapse WITH PASSWORD :'synapse_password';
GRANT ALL PRIVILEGES ON DATABASE synapse TO synapse;

-- Keycloak
CREATE DATABASE keycloak
    ENCODING 'UTF8'
    LC_COLLATE='C'
    LC_CTYPE='C'
    TEMPLATE template0;

CREATE USER keycloak WITH PASSWORD :'keycloak_password';
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;

-- Grant schema write access (required in PostgreSQL 15+, which DO managed uses)
\c synapse
GRANT ALL ON SCHEMA public TO synapse;

\c keycloak
GRANT ALL ON SCHEMA public TO keycloak;
