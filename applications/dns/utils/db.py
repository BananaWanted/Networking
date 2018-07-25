#!/usr/bin/env python3
import asyncio
from functools import wraps, partial

from sanic import Sanic
from sanic.request import Request
from sqlalchemy.engine import Engine, create_engine
from sqlalchemy.orm import sessionmaker, Session

from utils.async_run import arun


def setup_sqlalchemy(app: Sanic):
    app.engine = create_engine(
        'postgresql://{user}:{password}@{host}:{port}'.format(
            host=app.config.DB_HOST,
            port=app.config.DB_PORT,
            user=app.config.DB_USERNAME,
            password=app.config.DB_PASSWORD,
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


def enable_session(view):
    @wraps(view)
    async def wrapper(request: Request, *args, **kwargs):
        request.app.session: Session = request.app.session_class()
        request.app.session_flush = partial(arun, request.app.session.flush)
        request.app.session.commit = partial(arun, request.app.session.commit)
        request.app.session.rollback = partial(arun, request.app.session.rollback)
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
