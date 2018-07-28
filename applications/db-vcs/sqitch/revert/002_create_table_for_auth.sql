-- Revert Main:002_create_table_for_auth from pg

BEGIN;

DROP TABLE auth_grant_password;

DROP FUNCTION verify_password(VARCHAR(72), VARCHAR(60));

DROP FUNCTION hash_password(VARCHAR(72));

DROP TABLE auth_grant_email_validate;

DROP TABLE auth_flags;

DROP TYPE permission_flag;

DROP TYPE grant_flag;

COMMIT;
