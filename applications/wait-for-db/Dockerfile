ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sqitch:${BUILD_TAG}

COPY wait_for_db.sh /wait_for_db.sh
CMD /wait_for_db.sh
