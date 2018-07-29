#!/usr/bin/env python3

import enum
from datetime import datetime
from enum import auto
from functools import reduce
from typing import List

from gino.ext.sanic import Gino
from sqlalchemy import and_

db = Gino()


class GrantPolicyFlag(enum.Enum):
    REQUIRED = auto()
    OPTIONAL = auto()
    BYPASSED = auto()


class PermissionFlag(enum.Enum):
    ALLOW = auto()
    DENY = auto()


class GrantController:
    @classmethod
    async def create_from_context(cls, auth_context: dict):
        pass


class UserIdentifiers(db.Model):
    __tablename__ = "user_identifiers"

    id = db.Column(db.BIGINT, primary_key=True)
    email = db.Column(db.VARCHAR)
    created_time = db.Column(db.DateTime, default=datetime.utcnow)
    updated_time = db.Column(db.DateTime, default=datetime.utcnow)


class AuthGrantEmailValidate(db.Model, GrantController):
    __tablename__ = "auth_grant_email_validate"

    user_id = db.Column(db.BIGINT, db.ForeignKey("user_identifiers.id"), primary_key=True)
    created_time = db.Column(db.DateTime, default=datetime.utcnow)
    updated_time = db.Column(db.DateTime, default=datetime.utcnow)
    grant_policy = db.Column(db.Enum(GrantPolicyFlag), default=GrantPolicyFlag.REQUIRED)

    validate_status = db.Column(db.Boolean, default=False)


class AuthGrantPassword(db.Model, GrantController):
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


class User:
    user_identifiers: UserIdentifiers
    permission_flags: AuthPermissionFlags
    grant_controllers: List[GrantController]

    @classmethod
    async def new_user(cls, email: str, auth_context: dict):
        self = cls()
        # TODO: validate email format
        self.user_identifiers = await UserIdentifiers.create(email=email)
        self.permission_flags = await AuthPermissionFlags.create(user_id=self.user_identifiers.id)

        auth_context.update({
            "email": email,
            "user_id": self.user_identifiers.id,
        })

        for controller_cls in (AuthGrantEmailValidate, AuthGrantPassword):
            self.grant_controllers.append(await controller_cls.create_from_context(auth_context))

        return self

    @classmethod
    async def load_user(cls, user_id=None, email=None):
        self = cls()
        conds = []
        if user_id:
            conds.append(UserIdentifiers.id == user_id)
        if email:
            conds.append(UserIdentifiers.email == email)
        if not conds:
            raise ValueError("either user_id or email should be provided to find a user")
        where = reduce(lambda x, y: and_(x, y), conds[1:], conds[0])
        self.user_identifiers = await UserIdentifiers.query.where(where).gino.one()
        self.permission_flags = await AuthPermissionFlags.query.where(AuthPermissionFlags.user_id == self.user_identifiers.id).gino.one()
        self.grant_controllers = []
        for controller_cls in (AuthGrantEmailValidate, AuthGrantPassword):
            self.grant_controllers.append(await controller_cls.query.where(controller_cls.user_id == self.user_identifiers.id).gino.one())
        return self

    async def update_user(self):
        pass
