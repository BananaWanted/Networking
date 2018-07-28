-- Revert Main:002_create_table_for_auth from pg

BEGIN;

DROP TABLE auth_grant_password;

DROP TABLE auth_grant_email_validate;

DROP TABLE auth_permission_flags;

DROP TYPE permission_flag;

DROP TYPE grant_policy_flag;

COMMIT;
