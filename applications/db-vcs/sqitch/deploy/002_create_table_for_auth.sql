-- Deploy Main:002_create_table_for_auth to pg

BEGIN;

-- REQUIRED: grant method is mandatory. user must pass the check to get access.
-- OPTIONAL: user must pass one of the checks marked as 'OPTIONAL' to get access.
--      so, if exactly one MAY appears in a single row, it equals to 'MUST'.
-- BYPASSED: this check is bypassed, which means, when an checked is performed on an
--      "bypassed" grant type, it would always pass.
-- NULL: not defined, let auth_service decide.
CREATE TYPE grant_flag as ENUM ('REQUIRED', 'OPTIONAL', 'BYPASSED');

-- ALLOW: give access to the resource.
-- DENY: refuse access to the resource.
-- NULL: let the resource itself decide.
CREATE TYPE permission_flag as ENUM ('ALLOW', 'DENY');

CREATE TABLE auth_flags (
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',

    grant_email_validate    grant_flag                      NULL    DEFAULT 'REQUIRED',
    grant_password          grant_flag                      NULL    DEFAULT 'OPTIONAL',

    resource_ddns           permission_flag                 NULL    DEFAULT NULL,
    resource_server_info    permission_flag                 NULL    DEFAULT NULL,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES user_identifiers(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE auth_grant_email_validate (
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',

    validate_status         boolean                     NOT NULL    DEFAULT FALSE,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES auth_flags(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE auth_grant_password (
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',

    password                text                        NOT NULL,
    expired                 boolean                     NOT NULL    DEFAULT FALSE,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES auth_flags(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE FUNCTION hash_password(password VARCHAR(72)) RETURNS VARCHAR(60) AS $$
BEGIN
    RETURN crypt(password, gen_salt('bf'));
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION verify_password(password VARCHAR(72), hashed VARCHAR(60)) RETURNS boolean AS $$
BEGIN
    IF password IS NULL OR hashed IS NULL THEN
        RETURN FALSE;
    ELSE
        RETURN crypt(password, hashed) = hashed;
    END IF;
END;
$$ LANGUAGE plpgsql CALLED ON NULL INPUT;

COMMIT;

-- table template:
-- CREATE TABLE auth_grant_xxx (
--     user_id                 BIGINT                      NOT NULL,
--     created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
--     updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
--
--     PRIMARY KEY (user_id),
--     FOREIGN KEY (user_id) REFERENCES auth_flags(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
-- );
