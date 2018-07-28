-- Revert Main:001_create_table_for_ddns from pg

BEGIN;

DROP TABLE ddns_remote_report;

DROP TABLE ddns_record;

DROP TABLE user_identifiers;

DROP FUNCTION gen_random_id_for_human();

DROP EXTENSION pgcrypto;

COMMIT;
