#!/usr/bin/env python3
"""
This file is only for running sanic image test. Not included in prod image.
"""
from gino import Gino

db = Gino()