#!/usr/bin/env python3
import uuid
from datetime import datetime

from gino.ext.sanic import Gino
from sqlalchemy.dialects.postgresql import INET

db = Gino()


class DDNSRecord(db.Model):
    __tablename__ = 'ddns_record'

    user_id = db.Column(db.BIGINT, db.ForeignKey("user_identifiers.id"))
    created_time = db.Column(db.DateTime, default=datetime.utcnow)
    updated_time = db.Column(db.DateTime, default=datetime.utcnow)

    secret_id = db.Column(db.VARCHAR, default=lambda: uuid.uuid4().hex, primary_key=True)
    public_id = db.Column(db.VARCHAR, default=lambda: uuid.uuid4().hex)


class DDNSRemoteReport(db.Model):
    __tablename__ = 'ddns_remote_report'

    user_id = db.Column(db.BIGINT, db.ForeignKey("user_identifiers.id"))
    created_time = db.Column(db.DateTime, default=datetime.utcnow)

    id = db.Column(db.BIGINT, primary_key=True)
    secret_id = db.Column(db.VARCHAR, db.ForeignKey('ddns_record.secret_id'))
    ip = db.Column(INET)
