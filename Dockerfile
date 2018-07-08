FROM python:3

ENV WORKERS=4

COPY . /workspace
WORKDIR /workspace
RUN apt-get update \
    && apt-get install -y python3-psycopg2 postgresql-client \
    && pip install -r requirements.txt

EXPOSE 80

ENTRYPOINT ["/workspace/entrypoint.sh"]
#CMD python -m sanic application.app.app --host=0.0.0.0 --port=80 --workers=${WORKERS}
CMD gunicorn application.app:app \
    --worker-class sanic.worker.GunicornWorker \
    --bind=0.0.0.0:80 \
    --access-logfile - \
    --error-logfile -
