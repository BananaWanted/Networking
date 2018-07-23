FROM docteurklein/sqitch:pgsql

RUN apk update \
    && apk --no-cache add perl \
    && apk --no-cache add --virtual build-dependencies postgresql-dev make curl tar wget \
    && curl -LO https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm \
    && chmod +x cpanm \
    && ./cpanm App::cpanminus \
    && cpanm App::Sqitch DBD::Pg -n \
    && rm -rf ./cpanm /root/.cpanm /usr/src/perl \
    && apk del --purge build-dependencies
