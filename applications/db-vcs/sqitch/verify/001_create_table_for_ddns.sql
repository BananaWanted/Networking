-- Verify Main:001_create_table_for_ddns on pg

BEGIN;

SELECT has_function_privilege('gen_random_id_for_human()', 'execute');

SELECT gen_random_id_for_human();

INSERT INTO user_identifiers (email) VALUES ('haha@a.com');

SELECT id, email, created_time, updated_time FROM user_identifiers WHERE email = 'haha@a.com';

INSERT INTO ddns_record (user_id) SELECT id AS user_id FROM user_identifiers WHERE email = 'haha@a.com';

INSERT INTO ddns_remote_report (user_id, secret_id, ip)
    SELECT user_id, secret_id, '192.168.1.1' FROM ddns_record JOIN user_identifiers ON user_id = user_identifiers.id
    WHERE user_identifiers.email = 'haha@a.com' LIMIT 1;

SELECT * FROM ddns_remote_report;

ROLLBACK;
