FROM ubuntu:16.04

ENV GOSU_VERSION 1.7
ENV GPG_KEYS \
	DFFA3DCF326E302C4787673A01C4E7FAAAB2461C \
	42F3E95A2C4F08279C4960ADD68FA50FEA312927
ENV MONGO_MAJOR 3.2
ENV MONGO_VERSION 3.2.10
ENV MONGO_PACKAGE mongodb-org

VOLUME /data/db /data/configdb

RUN groupadd -r mongodb && useradd -r -g mongodb mongodb \
	&& apt-get update && apt-get upgrade \
	&& apt-get install -y --no-install-recommends \
		numactl \
	&& rm -rf /var/lib/apt/lists/* \
	&& set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove wget \
	&& set -ex \
	&& for key in $GPG_KEYS; do \
		apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done \
	&& echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/$MONGO_MAJOR main" > /etc/apt/sources.list.d/mongodb-org.list \
	&& set -x \
	&& apt-get update \
	&& apt-get install -y \
		${MONGO_PACKAGE}=$MONGO_VERSION \
		${MONGO_PACKAGE}-server=$MONGO_VERSION \
		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* /var/tmp/* \
	&& rm -rf /var/lib/mongodb /var/cache/* \
	&& apt-get autoremove -y && apt-get clean \
	&& mv /etc/mongod.conf /etc/mongod.conf.orig \
	&& mkdir -p /data/db /data/configdb \
	&& mkdir -p /data/entry \
	&& chown -R mongodb:mongodb /data/db /data/configdb

COPY entrypoint.sh /data/entry/entrypoint.sh

RUN chmod +x /data/entry/entrypoint.sh
EXPOSE 27017

ENTRYPOINT ["/data/entry/entrypoint.sh"]
