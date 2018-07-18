#!/usr/bin/env python3
import asyncio
from uuid import UUID

import google.cloud.dns
from sanic.exceptions import NotFound
from sanic.request import Request
from sanic.response import text
from sanic.views import HTTPMethodView

from application.dns.orm import Client, ClientIPReport
from application.setup.db import enable_session, async_sqlalchemy


class ClientReportView(HTTPMethodView):

    decorators = [enable_session]

    async def get(self, request: Request, secret_id: str):

        query = request.app.session.query(Client).filter(Client.secret_id == secret_id)
        client = await async_sqlalchemy(query.one)
        report = ClientIPReport(secret_id=secret_id, ip=request.ip)
        request.app.session.add(report)

        endpoint = "{}.{}.".format(client.public_id.hex, request.app.config.DNS_ZONE)
        await asyncio.get_event_loop().run_in_executor(None, self.update_zone, endpoint, request.ip)
        return text("ok")

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
