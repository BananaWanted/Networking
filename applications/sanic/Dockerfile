FROM python:alpine

# system env
ENV PYTHONPATH="/workspace" WEB_CONCURRENCY=4 LANG=C.UTF-8 TERM=dumb
# app env
ENV APP_BLUEPRINT="blueprint.bp" APP_ORM="orm.db"

EXPOSE 80
WORKDIR /workspace

# Add files whiches are required for production.
COPY app.py requirements.txt ./

# Install dependencies & cleanup
RUN apk update \
    && apk --no-cache add libpq \
    && apk --no-cache add --virtual build-dependencies postgresql-dev gcc python3-dev libffi-dev libressl-dev musl-dev make \
    && pip install -r requirements.txt \
    && apk del --purge build-dependencies \
    && rm -f /requirements.txt

CMD ["/usr/local/bin/gunicorn", \
    "--worker-class", "sanic.worker.GunicornWorker", \
    "--bind=0.0.0.0:80", \
    "--access-logfile", "-", \
    "--error-logfile", "-", \
    "app:app"] 
