##############################################################################
# Dockerfile to build Atlassian Crowd container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ARG VERSION

ENV CROWD_INST /opt/crowd
ENV CROWD_HOME /var/opt/crowd
ENV SYSTEM_USER crowd
ENV SYSTEM_GROUP crowd
ENV SYSTEM_HOME /home/crowd

RUN set -x \
  && apk add su-exec tar xmlstarlet wget ca-certificates --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p ${CROWD_INST} \
  && mkdir -p ${CROWD_HOME}

RUN set -x \
  && mkdir -p ${SYSTEM_HOME} \
  && addgroup -S ${SYSTEM_GROUP} \
  && adduser -S -D -G ${SYSTEM_GROUP} -h ${SYSTEM_HOME} -s /bin/sh ${SYSTEM_USER} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${SYSTEM_HOME}

RUN set -x \
  && wget -nv -O /tmp/atlassian-crowd-${VERSION}.tar.gz https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${VERSION}.tar.gz \
  && tar xfz /tmp/atlassian-crowd-${VERSION}.tar.gz --strip-components=1 -C ${CROWD_INST} \
  && rm /tmp/atlassian-crowd-${VERSION}.tar.gz \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${CROWD_INST}

RUN set -x \
  && rm ${CROWD_INST}/apache-tomcat/conf/Catalina/localhost/demo.xml \
  && rm ${CROWD_INST}/apache-tomcat/conf/Catalina/localhost/openidserver.xml \
  && rm ${CROWD_INST}/apache-tomcat/conf/Catalina/localhost/openidclient.xml

RUN set -x \
  && touch -d "@0" "${CROWD_INST}/apache-tomcat/conf/server.xml" \
  && touch -d "@0" "${CROWD_INST}/apache-tomcat/bin/setenv.sh" \
  && touch -d "@0" "${CROWD_INST}/crowd-webapp/WEB-INF/classes/crowd-init.properties"

ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint

EXPOSE 8009 8095

VOLUME ${CROWD_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/local/bin/service"]
