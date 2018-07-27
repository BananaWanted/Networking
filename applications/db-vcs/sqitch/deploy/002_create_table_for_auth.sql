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
    created_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),

    grant_email_validate    grant_flag                      NULL    DEFAULT 'MUST',
    grant_password          grant_flag                      NULL    DEFAULT 'OPTIONAL',
    grant_session           grant_flag                      NULL    DEFAULT 'OPTIONAL',

    resource_ddns           permission_flag                 NULL,
    resource_server_info    permission_flag                 NULL,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES user_ident(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE auth_grant_email_validate (
    user_id                 BIGINT                      NOT NULL,
    created_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),
    updated_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),

    validate_status         boolean                     NOT NULL    DEFAULT 'false',

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES auth_flags(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE auth_grant_password (
    user_id                 BIGINT                      NOT NULL,
    created_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),
    updated_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),

    password                text                        NOT NULL,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES auth_flags(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE auth_grant_session (
    user_id                 BIGINT                      NOT NULL,
    created_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),

    session_key             message_text                NOT NULL,
    last_seen               TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),

    PRIMARY KEY (session_key),
    FOREIGN KEY (user_id) REFERENCES auth_flags(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMIT;

-- table template:
-- CREATE TABLE auth_grant_xxx (
--     user_id                 BIGINT                      NOT NULL,
--     created_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),
--     updated_time            TIMESTAMP WITHOUT TIME ZONE NOT NULL    DEFAULT now(),
--
--     PRIMARY KEY (user_id),
--     FOREIGN KEY (user_id) REFERENCES auth_flags(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
-- );
