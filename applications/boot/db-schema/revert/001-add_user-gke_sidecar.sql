-- Revert Networking:001-add_user-gke_sidecar from pg

BEGIN;

DROP USER gke_sidecar;

COMMIT;
