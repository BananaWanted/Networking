#!/usr/bin/env python3
"""
This file is only for running sanic image test. Not included in prod image.
"""
from sanic import Blueprint

bp = Blueprint('bp', '/bp')