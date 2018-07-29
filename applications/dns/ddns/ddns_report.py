#!/usr/bin/env python3
import asyncio
from textwrap import dedent

import google.cloud.dns
from sanic.exceptions import NotFound
from sanic.request import Request
from sanic.response import text
from sanic.views import HTTPMethodView

from orm import DDNSRecord, DDNSRemoteReport, db


class DDNSReportView(HTTPMethodView):
    async def get(self, request: Request, secret_id):
        async with db.transaction():
            record = await DDNSRecord.get(secret_id)
            await DDNSRemoteReport(
                user_id=record.user_id,
                secret_id=secret_id,
                ip=request.ip).create()
        # release the DB connection, since Google Cloud operations are time consuming.
        endpoint = "{}.{}.".format(record.public_id, request.app.config.DDNS_ZONE)
        if request.app.config.get("TESTING"):
            return text(dedent(f"""\
            set endpoint {endpoint} to ip {request.ip}
            """))
        else:
            # un-blocking the main thread
            # but the operation is still blocking.
            await asyncio.get_event_loop().run_in_executor(None, self.update_zone, endpoint, request.ip)
            return text(endpoint)


    @staticmethod
    def update_zone(endpoint, ip):
        client = google.cloud.dns.Client()
        for zone in client.list_zones():
            zone: google.cloud.dns.zone.ManagedZone
            if endpoint.endswith(zone.dns_name):
                break
        else:
            raise NotFound("setup not found")

        changes = zone.changes()

        for old_record in zone.list_resource_record_sets():
            old_record: google.cloud.dns.resource_record_set.ResourceRecordSet
            print(old_record.name)
            if old_record.name == endpoint:
                changes.delete_record_set(old_record)

        new_record = zone.resource_record_set(endpoint, 'A', 60 * 5, [ip])
        changes.add_record_set(new_record)
        changes.create()

        while changes.status != 'done':
            asyncio.sleep(1)
            changes.reload()
