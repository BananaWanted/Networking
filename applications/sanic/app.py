from sanic import Sanic
from sanic.response import text

app = Sanic()


@app.route("/")
def index(request):
    return text("sanic is running!")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
