-- Deploy Main:001_create_table_for_ddns to pg

BEGIN;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp"

CREATE TABLE ddns_clisnt (
    secret_id UUID DEFAULT gen_random_uuid() NOT NULL,
    public_id UUID DEFAULT gen_random_uuid() NOT NULL,
    created_time TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    PRIMARY KEY (secret_id)
);

CREATE TABLE ddns_client_ip_report (
    id BIGSERIAL NOT NULL,
    secret_id UUID NOT NULL,
    ip INET NOT NULL,
    created_time TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    PRIMARY KEY (id)
);

COMMIT;
