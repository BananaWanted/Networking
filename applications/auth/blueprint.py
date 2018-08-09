#!/usr/bin/env python3

from sanic import Blueprint

from views import AuthDescribe, AuthGetToken, AuthCreateRole

bp = Blueprint('auth', '/auth')

[bp.add_route(handler, path) for handler, path in [
    (AuthDescribe.as_view(), "/describe/<identifier_type>/<identifier>"),  # describe identifier (user_id / email / token)
    (AuthGetToken.as_view(), "/get_token/"),     # verify identity and produce an access token
    (AuthCreateRole.as_view(), "/create_role/"),    # create user
]]
