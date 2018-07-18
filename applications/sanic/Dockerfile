FROM python:alpine

ENV WEB_CONCURRENCY=4
EXPOSE 80

COPY . /workspace
WORKDIR /workspace
RUN apk update \
    && apk add py3-psycopg2 \
    && pip install -r requirements.txt \
    && rm -rf .

CMD ["/usr/local/bin/gunicorn", "--worker-class", "sanic.worker.GunicornWorker", "--bind=0.0.0.0:80", \
    "--access-logfile", "-", \
    "--error-logfile", "-", \
    "app:app"] 
