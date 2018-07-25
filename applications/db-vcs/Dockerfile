ARG DOCKER_REGISTRY
ARG BUILD_TAG
FROM ${DOCKER_REGISTRY}/sqitch:${BUILD_TAG}

COPY sqitch .

CMD /usr/local/bin/sqitch deploy --verify db:pg://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}