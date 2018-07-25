#!/usr/bin/env python3
import uuid

from sqlalchemy import Column, DateTime, ForeignKey, BIGINT, VARCHAR
from sqlalchemy.dialects.postgresql import INET
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class DDNSRecord(Base):
    __tablename__ = 'ddns_record'

    user_id = Column(BIGINT)
    secret_id = Column(VARCHAR, default=lambda: uuid.uuid4().hex, primary_key=True)
    public_id = Column(VARCHAR, default=lambda: uuid.uuid4().hex)
    created_time = Column(DateTime)


class DDNSRemoteReport(Base):
    __tablename__ = 'ddns_remote_report'

    id = Column(BIGINT, primary_key=True)
    user_id = Column(BIGINT)
    secret_id = Column(VARCHAR, ForeignKey(DDNSRecord.secret_id))
    ip = Column(INET)
    created_time = Column(DateTime)
