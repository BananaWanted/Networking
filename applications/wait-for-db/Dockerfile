ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sqitch:${BUILD_TAG}

COPY waiting_for_db.sh /waiting_for_db.sh
CMD /waiting_for_db.sh
