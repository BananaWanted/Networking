#!/usr/bin/env python3
from uuid import uuid4

from sanic.request import Request
from sanic.response import text
from sanic.views import HTTPMethodView

from application.dns.orm import Client
from application.setup.db import enable_session


class ClientSetupView(HTTPMethodView):

    decorators = [enable_session]

    async def get(self, request: Request):
        client = Client()
        request.app.session.add(client)
        await request.app.session_flush()

        report_url = request.app.url_for(
            'dns.ClientReportView',
            secret_id=client.secret_id.hex,
            _external=True,
            _scheme=request.scheme,
            _server=request.host,
        )
        cname_host = "{}.{}".format(client.public_id.hex, request.app.config.DNS_ZONE)

        return text("{}\n{}".format(report_url, cname_host))
