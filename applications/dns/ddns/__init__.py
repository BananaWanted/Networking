#!/usr/bin/env python3
from sanic import Blueprint

from ddns.ddns_report import DDNSReportView
from ddns.ddns_setup import DDNSSetupView

bp = Blueprint('ddns', '/ddns')

bp.add_route(DDNSReportView.as_view(), '/report/<secret_id>')
bp.add_route(DDNSSetupView.as_view(), '/setup/<user_id>')
