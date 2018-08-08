# Template Dockerfile for All Sanic Based Testing Apps
ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sanic:${BUILD_TAG}-test

# Add tests files
COPY tests requirements.txt requirements-test.txt ./

# Install dependencies, no cleanup
RUN pip install -r requirements-test.txt