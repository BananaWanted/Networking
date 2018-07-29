#!/usr/bin/env python3
import os

from sanic import Sanic

from ddns import bp
from utils.db import setup_sqlalchemy, teardown_sqlalchemy

app = Sanic()

@app.listener('before_server_start')
def setup(app, loop):
    setup_sqlalchemy(app)


@app.listener('after_server_stop')
def teardown(app, loop):
    teardown_sqlalchemy(app)


app.blueprint(bp)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
