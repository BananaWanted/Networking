# Template Dockerfile for All Sanic Based Apps
ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sanic:${BUILD_TAG}

COPY . .
RUN pip install -r requirements.txt \
    && rm -rf test/ tests/ script/ scripts/ Dockerfile* requirements*