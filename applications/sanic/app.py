from importlib import import_module
from os import environ

from gino.ext.sanic import Gino
from sanic import Sanic, Blueprint
from sanic.request import Request
from sanic.response import text

app = Sanic()

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
