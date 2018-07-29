-- Deploy Main:001_create_table_for_ddns to pg

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;


CREATE FUNCTION gen_random_id_for_human() RETURNS VARCHAR(64) AS $$
BEGIN
    RETURN replace(gen_random_uuid()::text, '-', '');
END;
$$ LANGUAGE plpgsql;


CREATE TABLE user_identifiers (
    id                      BIGSERIAL                   NOT NULL,
    email                   VARCHAR(255)                NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT (now() AT TIME ZONE 'UTC'),
    updated_time            timestamp without time zone NOT NULL    DEFAULT (now() AT TIME ZONE 'UTC'),

    PRIMARY KEY (id),
    UNIQUE (email)
);


CREATE TABLE ddns_record (
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT (now() AT TIME ZONE 'UTC'),
    updated_time            timestamp without time zone NOT NULL    DEFAULT (now() AT TIME ZONE 'UTC'),

    secret_id               VARCHAR(255)                NOT NULL    DEFAULT gen_random_id_for_human(),
    public_id               VARCHAR(255)                NOT NULL    DEFAULT gen_random_id_for_human(),

    PRIMARY KEY (secret_id),
    FOREIGN KEY (user_id) REFERENCES user_identifiers(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE (secret_id),
    UNIQUE (public_id)
);


CREATE TABLE ddns_remote_report (
    id                      BIGSERIAL                   NOT NULL,
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT (now() AT TIME ZONE 'UTC'),

    secret_id               VARCHAR(255)                NOT NULL,
    ip                      INET                        NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES user_identifiers(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (secret_id) REFERENCES ddns_record(secret_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMIT;
