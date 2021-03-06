#!/usr/bin/env python3
from pytest import fixture, mark
from sanic import Sanic


@fixture
def app():
    from app import app as sanic_app
    sanic_app.debug = sanic_app.config.debug = True
    return sanic_app


@mark.skipif('os.environ.get("TEST_STAGE") == "BUILD"')
def test_sanic_app(app: Sanic):
    req, res = app.test_client.get('/status')
    assert res.status == 200


@mark.skipif('os.environ.get("TEST_STAGE") == "BUILD"')
def test_sanic_bp(app: Sanic):
    req, res = app.test_client.get('/bp/status')
    assert res.status == 200
