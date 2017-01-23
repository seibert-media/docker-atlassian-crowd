##############################################################################
# Dockerfile to build Atlassian Crowd container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ARG VERSION
ARG MYSQL_JDBC_VERSION

ENV CROWD_INST /opt/atlassian/crowd
ENV CROWD_HOME /var/opt/atlassian/application-data/crowd
ENV SYSTEM_USER crowd
ENV SYSTEM_GROUP crowd
ENV SYSTEM_HOME /home/crowd

RUN set -x \
  && apk add git tar xmlstarlet wget ca-certificates --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p ${CROWD_INST} \
  && mkdir -p ${CROWD_HOME}

RUN set -x \
  && mkdir -p /home/${SYSTEM_USER} \
  && addgroup -S ${SYSTEM_GROUP} \
  && adduser -S -D -G ${SYSTEM_GROUP} -h ${SYSTEM_GROUP} -s /bin/sh ${SYSTEM_USER} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} /home/${SYSTEM_USER}

RUN set -x \
  && wget -nv -O /tmp/atlassian-crowd-${VERSION}.tar.gz https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${VERSION}.tar.gz \
  && tar xfz /tmp/atlassian-crowd-${VERSION}.tar.gz --strip-components=1 -C ${CROWD_INST} \
  && rm /tmp/atlassian-crowd-${VERSION}.tar.gz \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${CROWD_INST} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${CROWD_HOME}

RUN set -x \
  && rm ${CROWD_INST}/apache-tomcat/conf/Catalina/localhost/demo.xml \
  && rm ${CROWD_INST}/apache-tomcat/conf/Catalina/localhost/openidserver.xml \
  && rm ${CROWD_INST}/apache-tomcat/conf/Catalina/localhost/openidclient.xml

RUN set -x \
  && wget -nv -O /tmp/mysql-connector-java-${MYSQL_JDBC_VERSION}.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_JDBC_VERSION}.tar.gz \
  && tar xfz /tmp/mysql-connector-java-${MYSQL_JDBC_VERSION}.tar.gz -C /tmp \
  && cp /tmp/mysql-connector-java-${MYSQL_JDBC_VERSION}/mysql-connector-java-${MYSQL_JDBC_VERSION}-bin.jar ${CROWD_INST}/apache-tomcat/lib/ \
  && rm /tmp/mysql-connector-java-${MYSQL_JDBC_VERSION}.tar.gz

RUN set -x \
  && touch -d "@0" "${CROWD_INST}/apache-tomcat/conf/server.xml" \
  && touch -d "@0" "${CROWD_INST}/apache-tomcat/bin/setenv.sh" \
  && touch -d "@0" "${CROWD_INST}/crowd-webapp/WEB-INF/classes/crowd-init.properties"

ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint

RUN set -x \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} /usr/local/bin/service \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} /usr/local/bin/entrypoint

EXPOSE 8095
EXPOSE 8009

USER ${SYSTEM_USER}

VOLUME ${CROWD_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/local/bin/service"]
