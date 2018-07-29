#!/usr/bin/env python3
from textwrap import dedent

from sanic.request import Request
from sanic.response import text
from sanic.views import HTTPMethodView

from orm import DDNSRecord, db


class DDNSSetupView(HTTPMethodView):
    async def get(self, request: Request, user_id: int):
        async with db.transaction():
            record = await DDNSRecord(user_id=user_id).create()

            report_url = request.app.url_for(
                'ddns.DDNSReportView',
                secret_id=record.secret_id,
                _external=True,
                _scheme=request.scheme,
                _server=request.host,
            )
            cname_host = "{}.{}".format(record.public_id, request.app.config.DDNS_ZONE)

            return text(dedent(f"""\
                report to {report_url}
                set cname target to {cname_host}
                """))
