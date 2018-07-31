#!/usr/bin/env python3

from sanic import Sanic
from sanic.request import Request
from sanic.response import text

from models import db
from views import AuthDescribe, AuthGetToken, AuthCreateRole

app = Sanic()

# create alias for db settings. which names are required by GINO Sanic extension
if app.config.get('DB_USERNAME'):
    app.config.DB_USER = app.config.DB_USERNAME
    app.config.DB_DATABASE = app.config.DB_USERNAME
db.init_app(app)


[app.add_route(handler, path) for handler, path in [
    (AuthDescribe.as_view(), "/auth/describe/<identifier_type>/<identifier>"),  # describe identifier (user_id / email / token)
    (AuthGetToken.as_view(), "/auth/get_token/"),     # verify identity and produce an access token
    (AuthCreateRole.as_view(), "/auth/create_role/"),    # create user
]]


@app.route("/")
def health_check(request):
    return text("ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
