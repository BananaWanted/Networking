#!/usr/bin/env python3

from sanic.request import Request
from sanic.response import text
from sanic.views import HTTPMethodView

from ddns.orm import DDNSRecord
from utils.db import enable_session


class DDNSSetupView(HTTPMethodView):

    decorators = [enable_session]

    async def get(self, request: Request, user_id: int):
        record = DDNSRecord(user_id=user_id)
        request.app.session.add(record)
        await request.app.session_flush()

        report_url = request.app.url_for(
            'ddns.DDNSReportView',
            secret_id=record.secret_id,
            _external=True,
            _scheme=request.scheme,
            _server=request.host,
        )
        cname_host = "{}.{}".format(record.public_id, request.app.config.DDNS_ZONE)

        return text("{}\n{}".format(report_url, cname_host))
