FROM python:alpine

ENV WEB_CONCURRENCY=4 LANG=C.UTF-8
EXPOSE 80

COPY . /workspace
WORKDIR /workspace
RUN apk update \
    && apk --no-cache add --virtual build-dependencies postgresql-dev gcc python3-dev musl-dev make \
    && pip install -r requirements.txt \
    && apk del --purge build-dependencies \
    && rm -rf *

CMD ["/usr/local/bin/gunicorn", "--worker-class", "sanic.worker.GunicornWorker", "--bind=0.0.0.0:80", \
    "--access-logfile", "-", \
    "--error-logfile", "-", \
    "app:app"] 
