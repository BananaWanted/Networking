#!/usr/bin/env python3

from sanic import Sanic
from sanic.response import json

app = Sanic()


@app.route("/generate_204")
def generate_204(request):
    return json(None, 204)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
