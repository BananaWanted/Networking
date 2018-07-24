ARG DOCKER_HUB_USERNAME
ARG BUILD_TAG
FROM ${DOCKER_HUB_USERNAME}/sqitch:${BUILD_TAG}

COPY sqitch .

CMD /usr/local/bin/sqitch deploy --verify db:pg://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}