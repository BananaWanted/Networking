-- Verify Main:001_create_table_for_ddns on pg

BEGIN;

SELECT has_function_privilege('gen_random_id_for_human()', 'execute');

SELECT gen_random_id_for_human();

INSERT INTO user_ident (email) VALUES ('haha@a.com');

INSERT INTO ddns_record_setup (user_id) SELECT id AS user_id FROM user_ident WHERE email = 'haha@a.com';

INSERT INTO ddns_remote_report_history (user_id, secret_id, ip)
    SELECT user_id, secret_id, '192.168.1.1'FROM ddns_record_setup JOIN user_ident ON user_id = user_ident.id
    WHERE user_ident.email = 'haha@a.com' LIMIT 1;

SELECT * FROM ddns_remote_report_history;

ROLLBACK;
