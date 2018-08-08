#!/usr/bin/env python3
"""
This file is only for running sanic image test. Not included in prod image.
"""
from sanic import Blueprint
from sanic.request import Request
from sanic.response import text

bp = Blueprint('bp', '/bp')

@bp.route("/status")
def status(request: Request):
    return text("sanic blueprint is running!")
