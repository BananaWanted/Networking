# Template Dockerfile for All Sanic Based Testing Apps
ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sanic:${BUILD_TAG}-test

COPY . .
RUN pip install -r requirements.txt \
    && pip install -r requirements-test.txt
