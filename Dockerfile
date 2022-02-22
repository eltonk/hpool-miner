FROM --platform=linux/amd64 alpine:3.15 as builder

WORKDIR /tmp

RUN apk add --no-cache bash unzip

RUN wget https://github.com/hpool-dev/chiapp-miner/releases/download/1.5.3/HPool-Miner-chia-pp-v1.5.3-2-linux.zip \
    && unzip -p HPool-Miner-chia-pp-v1.5.3-2-linux.zip linux/hpool-miner-chia-linux-amd64 > hpool-chiapp-miner \
    && chmod +x hpool-chiapp-miner

FROM ubuntu:focal

RUN groupadd -r chia && useradd -r -m -g chia chia && usermod -a -G users,chia chia

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates curl gosu tini

WORKDIR /opt

COPY --from=builder /tmp/hpool-chiapp-miner /opt/hpool-chiapp-miner
COPY docker-entrypoint.sh /opt/entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["tini", "--", "/opt/entrypoint.sh"]

CMD ["/opt/hpool-chiapp-miner"]