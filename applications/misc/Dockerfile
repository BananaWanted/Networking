# Template Dockerfile for All Sanic Based Apps
ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sanic:${BUILD_TAG}

# this app doesn't connect to db
ENV APP_ORM=""

# Add the default entrypoint & requirements of the app
COPY blueprint.py requirements.txt ./

# Install dependencies & cleanup
RUN pip install -r requirements.txt \
    && rm -f requirements.txt