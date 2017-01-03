# docker-atlassian-crowd

This is a Docker-Image for Atlassian Crowd based on [Alpine Linux](http://alpinelinux.org/), which is kept as small as possible.

## Features

* Small image size
* Setting JVM xms and xmx values
* Setting proxy parameters in server.xml to run it behind a reverse proxy (TOMCAT_PROXY_* ENV)
* Includes MySQL JDBC driver

## Variables

* TOMCAT_PROXY_NAME
* TOMCAT_PROXY_PORT
* TOMCAT_PROXY_SCHEME
* JVM_MEMORY_MIN
* JVM_MEMORY_MAX

## Ports
* 8095

## Build container
Specify the application version in the build command:

```bash
docker build --build-arg VERSION=x.x.x --build-arg MYSQL_JDBC_VERSION=5.1.40 .                                                        
```

## Getting started

Run Crowd standalone and navigate to `http://[dockerhost]:8095` to finish configuration:

```bash
docker run -tid -p 8095:8095 seibertmedia/atlassian-crowd:latest
```

Run Crowd standalone with customised jvm settings and navigate to `http://[dockerhost]:8095` to finish configuration:

```bash
docker run -tid -p 8095:8095 -e JVM_MEMORY_MIN=2g -e JVM_MEMORY_MAX=4g seibertmedia/atlassian-crowd:latest
```

Specify persistent volume for Crowd data directory:

```bash
docker run -tid -p 8095:8095 -v crowd_data:/var/opt/atlassian/application-data/crowd seibertmedia/atlassian-crowd:latest
```

Run Crowd behind a reverse (SSL) proxy and navigate to `https://identity.yourdomain.com`:

```bash
docker run -d -e TOMCAT_PROXY_NAME=identity.yourdomain.com -e TOMCAT_PROXY_PORT=443 -e TOMCAT_PROXY_SCHEME=https seibertmedia/atlassian-crowd:latest
```

Run Crowd behind a reverse (SSL) proxy with customised jvm settings and navigate to `https://identity.yourdomain.com`:

```bash
docker run -d -e TOMCAT_PROXY_NAME=identity.yourdomain.com -e TOMCAT_PROXY_PORT=443 -e TOMCAT_PROXY_SCHEME=https -e JVM_MEMORY_MIN=2g -e JVM_MEMORY_MAX=4g seibertmedia/atlassian-crowd:latest
```
