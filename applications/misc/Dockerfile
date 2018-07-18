FROM python:3

ENV WORKERS=4

COPY . /workspace
WORKDIR /workspace
RUN pip install -r requirements.txt

EXPOSE 80

CMD gunicorn application.app:app \
    --worker-class sanic.worker.GunicornWorker \
    --bind=0.0.0.0:80 \
    --access-logfile - \
    --error-logfile -
