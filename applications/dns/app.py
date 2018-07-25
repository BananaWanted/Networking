#!/usr/bin/env python3
import os

from sanic import Sanic

from ddns import bp
from utils.db import setup_sqlalchemy, teardown_sqlalchemy

app = Sanic()
# workaround 2 issues:
#   1. Sanic(load_env="") treat empty string as not specified
#   2. Sanic.config.load_environment_vars("") calls s.split(prefix, 1) which causes a failure
for k, v in os.environ.items():
    if not k.startswith('_') and not hasattr(app.config, k):
        if v.lower() == "true":
            app.config[k] = True
        elif v.lower() == "false":
            app.config[k] = False
        else:
            try:
                app.config[k] = int(v)
            except ValueError:
                try:
                    app.config[k] = float(v)
                except ValueError:
                    app.config[k] = v


@app.listener('before_server_start')
def setup(app, loop):
    setup_sqlalchemy(app)


@app.listener('after_server_stop')
def teardown(app, loop):
    teardown_sqlalchemy(app)


app.blueprint(bp)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
