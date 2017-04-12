FROM smebberson/alpine-base
MAINTAINER Santhosh Hirekerur <santhosh.hirekerur@tayloredtechnology.net>
ENV GOPATH /go
ENV SRCPATH ${GOPATH}/src/github.com/adnanh
ENV WEBHOOK_VERSION 2.6.3
env PATH /usr/local/bin:$PATH

RUN         apk add --update -t build-deps curl go git libc-dev gcc libgcc && \
            git config --global http.https://gopkg.in.followRedirects true && \
            curl -L -o /tmp/webhook-${WEBHOOK_VERSION}.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            mkdir -p ${SRCPATH} && tar -xvzf /tmp/webhook-${WEBHOOK_VERSION}.tar.gz -C ${SRCPATH} && \
            mv -f ${SRCPATH}/webhook-* ${SRCPATH}/webhook && \
            cd ${SRCPATH}/webhook && go get -d && go build -o /usr/local/bin/webhook && \
            apk del --purge build-deps && \
            rm -rf /var/cache/apk/* && \
            rm -rf ${GOPATH}


#ENTRYPOINT  ["/usr/local/bin/webhook"]

# 0@Cache -- Perma-Cached
# Applications that don't automatically link to the docker logs standard output go here
#RUN ln -sf /dev/stdout /var/log/nginx/access.log
# Important for all Debian based distributions
ENV DEBIAN_FRONTEND=noninteractive

# Volumes
VOLUME /grid-discovery

# Service Required Ports
EXPOSE 9000

# 1@Cache -- installs / binaries slow changing items
ENV REFRESHED_AT 2016-10-05

# In Alpine continers don't need to manually delete things --no-cache will clean up after itself
RUN apk --no-cache add jq


RUN mkdir -p /etc/webhook/scripts && mkdir -p /etc/webhook/data
ADD hooks.json /etc/webhook/hooks.json

# 2@Cache -- always Bust Cache to ensure pulling latest committed version
# Cook Medical will need to take out their own subscription to this service
#ADD https://www.amdoren.com/api/timezone.php?api_key=((insert key))&loc=Brisbane /tmp/bustcache
ADD /scripts /etc/webhook/scripts/
ADD /data /etc/webhook/data/
RUN chmod a+x /etc/webhook/scripts/*.sh

#adding run script

RUN mkdir -p /etc/services.d/webhook

RUN printf  '#!/usr/bin/with-contenv sh \n\
exec /usr/local/bin/webhook -verbose -hooks=/etc/webhook/hooks.json -hotreload \n'\
>> /etc/services.d/webhook/run

RUN chmod a+x /etc/services.d/webhook/*


ENTRYPOINT ["/init"]
#CMD ["-verbose", "-hooks=/etc/webhook/hooks.json", "-hotreload"]
#RUN chmod a+x /etc/webhook/data/*.json
