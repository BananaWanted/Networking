from importlib import import_module
from os import environ

from gino.ext.sanic import Gino
from sanic import Sanic, Blueprint
from sanic.request import Request
from sanic.response import text


class _PatchedRequest(Request):
    @property
    def scheme(self):
        forwarded_proto = self.headers.get('x-forwarded-proto') or self.headers.get('x-scheme')
        if forwarded_proto:
            return forwarded_proto
        else:
            return super(_PatchedRequest, self).scheme

    @property
    def host(self):
        forwarded_host = self.headers.get('host')
        if forwarded_host:
            return forwarded_host
        else:
            return super(_PatchedRequest, self).host

    @property
    def server_port(self):
        # new from original
        forwarded_port = self.headers.get('x-forwarded-port')
        if forwarded_port:
            return int(forwarded_port)
        else:
            _, port = self.transport.get_extra_info('sockname')
            return port

    # TODO leverage x-original-uri

    def url_for(self, view_name, **kwargs):
        # new from original
        return self.app.url_for(
            view_name,
            _request=self,
            **kwargs
        )


class _PatchedSanic(Sanic):
    def url_for(self, view_name: str, _request: _PatchedRequest, **kwargs):
        scheme = _request.scheme
        host = _request.host
        port = _request.server_port

        if (scheme.lower() in ('http', 'ws') and port == 80) or (scheme.lower() in ('https', 'wss') and port == 443):
            netloc = host
        else:
            netloc = f"{host}:{port}"

        return super(_PatchedSanic, self).url_for(
            view_name,
            _external=True,
            _scheme=scheme,
            _server=netloc,
            **kwargs,
        )


app = _PatchedSanic(request_class=_PatchedRequest)

# Set testing mode
if app.config.get('TESTING'):
    app.debug = app.config.debug = True

# Init DB model
APP_ORM_PATH: str = environ.get('APP_ORM')
if APP_ORM_PATH:
    if app.config.get('DB_USERNAME'):
        # create alias for db settings. which names are required by GINO Sanic extension
        app.config.DB_USER = app.config.DB_USERNAME
        app.config.DB_DATABASE = app.config.DB_USERNAME
    else:
        raise RuntimeError("DB settings not set")

    path_fragments = APP_ORM_PATH.split(".")
    assert len(path_fragments) >= 2, f"Invalid APP_ORM_PATH={APP_ORM_PATH}"
    module_name = ".".join(path_fragments[:-1])
    obj_name = path_fragments[-1]
    orm_module = import_module(module_name)
    db_obj: Gino = getattr(orm_module, obj_name)
    db_obj.init_app(app)

# Attach blueprint
BLUEPRINT_PATH = environ["APP_BLUEPRINT"]
path_fragments = BLUEPRINT_PATH.split(".")
assert len(path_fragments) >= 2, f"Invalid APP_BLUEPRINT={BLUEPRINT_PATH}"
module_name = ".".join(path_fragments[:-1])
obj_name = path_fragments[-1]
bp_module = import_module(module_name)
bp_obj: Blueprint = getattr(bp_module, obj_name)
app.blueprint(bp_obj)


# Setup health check endpoint
@app.route("/status")
def status(request: Request):
    return text("sanic is running!")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
