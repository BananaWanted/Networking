#!/usr/bin/env python3
from textwrap import dedent

from asyncpg import ForeignKeyViolationError
from sanic.exceptions import InvalidUsage
from sanic.request import Request
from sanic.response import text
from sanic.views import HTTPMethodView

from orm import DDNSRecord, db


class DDNSSetupView(HTTPMethodView):
    async def get(self, request: Request, user_id):
        try:
            user_id = int(user_id)
        except ValueError:
            raise InvalidUsage("invalid user_id")

        async with db.transaction():
            try:
                record = await DDNSRecord(user_id=user_id).create()
            except ForeignKeyViolationError:
                raise InvalidUsage("invalid user_id")

            report_url = request.url_for(
                'ddns.DDNSReportView',
                secret_id=record.secret_id,
            )
            cname_host = "{}.{}".format(record.public_id, request.app.config.DDNS_ZONE)

            return text(dedent(f"""\
                report to {report_url}
                set cname target to {cname_host}
                """))
