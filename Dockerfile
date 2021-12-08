FROM anapsix/alpine-java:8_jdk_nashorn

# Define environment variables.
ENV MULE_HOME=/opt/mule MULE_VERSION=4.4.0 MULE_MD5=1d80bbd88bb0d65006282817dd551743 TZ=Europe/Madrid MULE_USER=mule

# SSL Cert for downloading mule zip
RUN apk --no-cache update apk --no-cache upgrade apk --no-cache add ca-certificates update-ca-certificates apk --no-cache add openssl apk add --update tzdata rm -rf /var/cache/apk/*

RUN adduser -D -g "" ${MULE_USER} ${MULE_USER}

RUN mkdir /opt/mule-standalone-${MULE_VERSION} ln -s /opt/mule-standalone-${MULE_VERSION} ${MULE_HOME} chown ${MULE_USER}:${MULE_USER} -R /opt/mule*

RUN echo ${TZ} > /etc/timezone

USER ${MULE_USER}

# Checksum
RUN cd ~ && wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz echo "${MULE_MD5}  mule-standalone-${MULE_VERSION}.tar.gz" | md5sum -c cd /opt tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz rm ~/mule-standalone-${MULE_VERSION}.tar.gz

# To use MuleSoft EE 
COPY /opt/mule/conf/muleLicenseKey.lic /opt/mule/conf/muleLicenseKey.lic

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Define working directory.
WORKDIR ${MULE_HOME}

CMD [ "/opt/mule/bin/mule"]

# Default http port
EXPOSE 8081
