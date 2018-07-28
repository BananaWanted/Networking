-- Deploy Main:002_create_table_for_auth to pg

BEGIN;

-- REQUIRED: grant type is mandatory. user must pass the check to get access.
-- OPTIONAL: user must pass one of the checks marked as 'OPTIONAL' to get access.
-- BYPASSED: this check is bypassed in grant checking.
CREATE TYPE grant_policy_flag as ENUM ('REQUIRED', 'OPTIONAL', 'BYPASSED');

-- ALLOW: give access to the resource.
-- DENY: refuse access to the resource.
-- NULL: let the resource itself decide.
CREATE TYPE permission_flag as ENUM ('ALLOW', 'DENY');

CREATE TABLE auth_permission_flags (
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',

    resource_ddns           permission_flag                 NULL    DEFAULT NULL,
    resource_server_info    permission_flag                 NULL    DEFAULT NULL,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES user_identifiers(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE auth_grant_email_validate (
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    grant_policy            grant_policy_flag           NOT NULL    DEFAULT 'REQUIRED',

    validate_status         boolean                     NOT NULL    DEFAULT FALSE,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES user_identifiers(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE auth_grant_password (
    user_id                 BIGINT                      NOT NULL,
    created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
    grant_policy            grant_policy_flag           NOT NULL    DEFAULT 'OPTIONAL',

    password                text                        NOT NULL,
    expired                 boolean                     NOT NULL    DEFAULT FALSE,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES user_identifiers(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMIT;

-- table templates:
-- CREATE TABLE auth_grant_xxx (
--     user_id                 BIGINT                      NOT NULL,
--     created_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
--     updated_time            timestamp without time zone NOT NULL    DEFAULT now() AT TIME ZONE 'UTC',
--     grant_policy            grant_policy_flag           NOT NULL    DEFAULT 'REQUIRED',
--
--      ...
--
--     PRIMARY KEY (user_id),
--     FOREIGN KEY (user_id) REFERENCES user_identifiers(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
-- );
