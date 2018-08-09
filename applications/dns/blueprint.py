#!/usr/bin/env python3
"""
This file is only for running sanic image test. Not included in prod image.
"""
from sanic import Blueprint

from views.ddns_report import DDNSReportView
from views.ddns_setup import DDNSSetupView

bp = Blueprint('ddns', '/ddns')

bp.add_route(DDNSReportView.as_view(), '/report/<secret_id>')
bp.add_route(DDNSSetupView.as_view(), '/setup/<user_id>')
