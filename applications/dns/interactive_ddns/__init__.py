#!/usr/bin/env python3
from sanic import Blueprint

from interactive_ddns import orm
from interactive_ddns.client_report import ClientReportView
from interactive_ddns.client_setup import ClientSetupView
from setup.db import init_table

bp = Blueprint('interactive_ddns', '/interactive_ddns')


@bp.listener('before_server_start')
def setup(app, loop):
    init_table(app.engine, orm.Base)


bp.add_route(ClientReportView.as_view(), '/report/<secret_id>')
bp.add_route(ClientSetupView.as_view(), '/setup')
