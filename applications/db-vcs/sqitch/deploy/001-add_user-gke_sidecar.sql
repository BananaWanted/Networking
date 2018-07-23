-- Deploy Networking:001-add_user-gke_sidecar to pg

BEGIN;

CREATE USER gke_sidecar WITH
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    LOGIN
    PASSWORD NULL;

COMMIT;
