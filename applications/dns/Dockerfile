ARG DOCKER_HUB_USERNAME
ARG BUILD_TAG
FROM ${DOCKER_HUB_USERNAME}/sanic:${BUILD_TAG}

COPY . .
RUN pip install -r requirements.txt \
    && rm -rf test/ tests/ script/ scripts/ Dockerfile* requirements*