VERSION ?= 2.11.0
MYSQL_JDBC_VERSION ?= 5.1.40
REGISTRY ?= docker.seibert-media.net

all: build upload clean
clean:
	docker rmi $(REGISTRY)/seibertmedia/atlassian-crowd:$(VERSION)
build:
	docker build --no-cache --rm=true --build-arg VERSION=$(VERSION) --build-arg MYSQL_JDBC_VERSION=$(MYSQL_JDBC_VERSION) -t $(REGISTRY)/seibertmedia/atlassian-crowd:$(VERSION) .
upload:
	docker push $(REGISTRY)/seibertmedia/atlassian-crowd:$(VERSION)
