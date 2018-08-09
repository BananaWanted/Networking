# Template Dockerfile for All Sanic Based Apps
ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sanic:${BUILD_TAG}

# Add the default entrypoint & requirements of the app
COPY blueprint.py orm.py requirements.txt ./

# Install dependencies & cleanup
RUN pip install -r requirements.txt \
    && rm -f requirements.txt