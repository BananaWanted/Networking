#!/usr/bin/env python3

from sanic import Sanic
from sanic.response import text

from ddns import bp
from orm import db

app = Sanic()

if app.config.get('TESTING'):
    app.debug = app.config.debug = True

# create alias for db settings. which names are required by GINO Sanic extension
if app.config.get('DB_USERNAME'):
    app.config.DB_USER = app.config.DB_USERNAME
    app.config.DB_DATABASE = app.config.DB_USERNAME
db.init_app(app)


app.blueprint(bp)


@app.route("/")
def health_check(request):
    return text("ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
