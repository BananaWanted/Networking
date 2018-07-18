#!/usr/bin/env python3
from sanic import Blueprint

from application.dns import orm
from application.dns.client_report import ClientReportView
from application.dns.client_setup import ClientSetupView
from application.setup.db import init_table

bp = Blueprint('interactive_ddns', '/interactive_ddns')


@bp.listener('before_server_start')
def setup(app, loop):
    init_table(app.engine, orm.Base)


bp.add_route(ClientReportView.as_view(), '/report/<secret_id>')
bp.add_route(ClientSetupView.as_view(), '/setup')
