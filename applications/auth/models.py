#!/usr/bin/env python3

import enum
from datetime import datetime
from enum import auto

from gino.ext.sanic import Gino

db = Gino()


class GrantPolicyFlag(enum.Enum):
    REQUIRED = auto()
    OPTIONAL = auto()
    BYPASSED = auto()


class PermissionFlag(enum.Enum):
    ALLOW = auto()
    DENY = auto()


class UserIdentifiers(db.Model):
    __tablename__ = "user_identifiers"

    id = db.Column(db.BIGINT, primary_key=True)
    email = db.Column(db.VARCHAR)
    created_time = db.Column(db.DateTime, default=datetime.utcnow)
    updated_time = db.Column(db.DateTime, default=datetime.utcnow)


class AuthGrantEmailValidate(db.Model):
    __tablename__ = "auth_grant_email_validate"

    user_id = db.Column(db.BIGINT, db.ForeignKey("user_identifiers.id"), primary_key=True)
    created_time = db.Column(db.DateTime, default=datetime.utcnow)
    updated_time = db.Column(db.DateTime, default=datetime.utcnow)
    grant_policy = db.Column(db.Enum(GrantPolicyFlag), default=GrantPolicyFlag.REQUIRED)

    validate_status = db.Column(db.Boolean, default=False)


class AuthGrantPassword(db.Model):
    __tablename__ = "auth_grant_password"

    user_id = db.Column(db.BIGINT, db.ForeignKey("user_identifiers.id"), primary_key=True)
    created_time = db.Column(db.DateTime, default=datetime.utcnow)
    updated_time = db.Column(db.DateTime, default=datetime.utcnow)
    grant_policy = db.Column(db.Enum(GrantPolicyFlag), default=GrantPolicyFlag.OPTIONAL)

    password = db.Column(db.TEXT)
    expired = db.Column(db.Boolean, default=False)


class AuthPermissionFlags(db.Model):
    __tablename__ = "auth_permission_flags"

    user_id = db.Column(db.BIGINT, db.ForeignKey("user_identifiers.id"), primary_key=True)
    created_time = db.Column(db.DateTime, default=datetime.utcnow)
    updated_time = db.Column(db.DateTime, default=datetime.utcnow)

    resource_ddns = db.Column(db.Enum(PermissionFlag))
    resource_server_info = db.Column(db.Enum(PermissionFlag))
