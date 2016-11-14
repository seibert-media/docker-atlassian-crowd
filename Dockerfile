##############################################################################
# Dockerfile to build Atlassian Crowd container images
# Based on anapsix/alpine-java:8_server-jre
##############################################################################

FROM anapsix/alpine-java:8_server-jre

MAINTAINER //SEIBERT/MEDIA GmbH <docker@seibert-media.net>

ENV VERSION  0.0.0

RUN set -x \
  && apk add git tar xmlstarlet --update-cache --allow-untrusted --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && rm -rf /var/cache/apk/*

RUN set -x \
  && mkdir -p /opt/atlassian/crowd \
  && mkdir -p /var/opt/atlassian/application-data/crowd

ADD https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-$VERSION.tar.gz /tmp

RUN set -x \
  && tar xvfz /tmp/atlassian-crowd-$VERSION.tar.gz --strip-components=1 -C /opt/atlassian/crowd \
  && rm /tmp/atlassian-crowd-$VERSION.tar.gz

RUN set -x \
  && sed --in-place 's/#crowd.home=\/var\/crowd-home/crowd.home=\/var\/opt\/atlassian\/application-data\/crowd/' /opt/atlassian/crowd/crowd-webapp/WEB-INF/classes/crowd-init.properties

RUN set -x \
  && touch -d "@0" "/opt/atlassian/crowd/apache-tomcat/conf/server.xml" \
  && touch -d "@0" "/opt/atlassian/crowd/apache-tomcat/bin/setenv.sh"

ADD files/entrypoint /usr/local/bin/entrypoint
ADD files/_.codeyard.com.crt /tmp/_codeyard.com.crt

RUN set -x \
  && /opt/jdk/bin/keytool -import -trustcacerts -noprompt -keystore /opt/jdk/jre/lib/security/cacerts -storepass changeit -alias CODEYARD -file /tmp/_codeyard.com.crt

RUN set -x \
  && chown -R daemon:daemon /usr/local/bin/entrypoint \
  && chown -R daemon:daemon /opt/atlassian/crowd \
  && chown -R daemon:daemon /var/opt/atlassian/application-data/crowd

EXPOSE 8095

USER daemon

ENTRYPOINT  ["/usr/local/bin/entrypoint"]
