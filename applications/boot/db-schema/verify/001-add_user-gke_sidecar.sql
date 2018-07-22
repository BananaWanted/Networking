-- Verify Networking:001-add_user-gke_sidecar on pg

BEGIN;

SELECT * from pg_roles WHERE rolename = 'gke_sidecar';

ROLLBACK;
