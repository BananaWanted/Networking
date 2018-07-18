#!/usr/bin/env python3
import uuid

from sqlalchemy import Column, DateTime, func, ForeignKey, BIGINT
from sqlalchemy.dialects.postgresql import UUID, INET
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()


class Client(Base):
    __tablename__ = 'client'

    secret_id = Column(UUID(as_uuid=True),
                       primary_key=True, nullable=False, unique=True, index=True,
                       default=uuid.uuid4,
                       server_default=func.gen_random_uuid())
    public_id = Column(UUID(as_uuid=True),
                       nullable=False, unique=True, index=True,
                       default=uuid.uuid4,
                       server_default=func.gen_random_uuid())
    created_time = Column(DateTime, nullable=False, server_default=func.now())


class ClientIPReport(Base):
    __tablename__ = 'client_ip_report'

    id = Column(BIGINT, primary_key=True, autoincrement=True)
    secret_id = Column(UUID(as_uuid=True),
                       ForeignKey(Client.secret_id), nullable=False, index=True)
    ip = Column(INET, nullable=False, index=True)
    created_time = Column(DateTime, nullable=False, server_default=func.now())
