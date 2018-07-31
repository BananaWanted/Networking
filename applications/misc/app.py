#!/usr/bin/env python3

from sanic import Sanic
from sanic.request import Request
from sanic.response import json, text

app = Sanic()


@app.route("/generate_204")
async def generate_204(request):
    return json(None, 204)


@app.route("/server-info")
async def server_info(request: Request):
    fetch_keys = [
        "json", "token", "form",
        "args", "raw_args", "cookies",
        "ip", "port", "remote_addr",
        "scheme", "host", "content_type", "path", "url", "headers"
    ]
    ret = {}
    for k in fetch_keys:
        try:
            ret[k] = getattr(request, "k")
        except BaseException as e:
            ret[k] = f'@@ error: {type(e)} {e} @@'
    return json({
        "json": request.json,
        "token": request.token,
        "form": request.form,
        "args": request.args,
        "raw_args": request.raw_args,
        "cookies": request.cookies,
        "ip": request.ip,
        "port": request.port,
        "remote_addr": request.remote_addr,
        "scheme": request.scheme,
        "host": request.host,
        "content_type": request.content_type,
        "path": request.path,
        "url": request.url,
        "headers": request.headers,
    })


@app.route("/")
def health_check(request):
    return text("ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
