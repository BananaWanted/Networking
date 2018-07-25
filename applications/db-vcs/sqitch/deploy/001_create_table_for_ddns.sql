-- Deploy Main:001_create_table_for_ddns to pg

BEGIN;

CREATE EXTENSION "pgcrypto";


CREATE FUNCTION gen_random_id_for_human() RETURNS VARCHAR(64) AS $$
BEGIN
    RETURN replace(gen_random_uuid()::text, '-', '');
END;
$$ LANGUAGE plpgsql;


CREATE TABLE user_ident (
    id      BIGSERIAL,
    email   VARCHAR(255)    NOT NULL,
    created_time TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    UNIQUE (email)
);


CREATE TABLE ddns_record (
    user_id     BIGINT          NOT NULL,
    secret_id   VARCHAR(255)    NOT NULL DEFAULT gen_random_id_for_human(),
    public_id   VARCHAR(255)    NOT NULL DEFAULT gen_random_id_for_human(),
    created_time TIMESTAMP WITHOUT TIME ZONE
                                NOT NULL DEFAULT now() ,

    PRIMARY KEY (secret_id),
    FOREIGN KEY (user_id) REFERENCES user_ident(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE (secret_id),
    UNIQUE (public_id)
);


CREATE TABLE ddns_remote_report (
    id          BIGSERIAL,
    user_id     BIGINT          NOT NULL,
    secret_id   VARCHAR(255)    NOT NULL,
    ip          INET            NOT NULL,
    created_time TIMESTAMP WITHOUT TIME ZONE
                                NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES user_ident(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (secret_id) REFERENCES ddns_record(secret_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMIT;