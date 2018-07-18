#!/usr/bin/env python3
import asyncio
from concurrent.futures.thread import ThreadPoolExecutor
from functools import wraps, partial

from sanic import Sanic
from sanic.request import Request
from sqlalchemy.engine import Engine, create_engine
from sqlalchemy.ext.declarative import DeclarativeMeta
from sqlalchemy.orm import sessionmaker, Session


def setup_sqlalchemy(app: Sanic):
    app.engine = create_engine(
        'postgresql://{user}:{password}@{host}/{database}'.format(
            host=app.config.DB_HOST,
            database=app.config.DB_NAME,
            user=app.config.DB_USER,
            password=app.config.DB_PASS,
        )
    )
    app.session_class = sessionmaker(app.engine)


def teardown_sqlalchemy(app: Sanic):
    app.session_class: sessionmaker
    app.session_class.close_all()
    del app.session_class

    app.engine: Engine
    app.engine.dispose()
    del app.engine


def init_table(engine: Engine, orm_base: DeclarativeMeta):
    orm_base.metadata.create_all(engine)


async def async_sqlalchemy(execution, *args):
    return await asyncio.get_event_loop().run_in_executor(None, execution, *args)


def enable_session(view):
    @wraps(view)
    async def wrapper(request: Request, *args, **kwargs):
        request.app.session: Session = request.app.session_class()
        request.app.session_flush = partial(async_sqlalchemy, request.app.session.flush)
        request.app.session.commit = partial(async_sqlalchemy, request.app.session.commit)
        request.app.session.rollback = partial(async_sqlalchemy, request.app.session.rollback)
        try:
            ret = view(request, *args, **kwargs)
            if asyncio.iscoroutine(ret):
                ret = await ret
            await request.app.session.commit()
            return ret
        except:
            await request.app.session.rollback()
            raise
        # finally:
        #     del request.app.session
        #     del request.app.session_flush
        #     del request.app.session.commit
        #     del request.app.session.rollback
    return wrapper
