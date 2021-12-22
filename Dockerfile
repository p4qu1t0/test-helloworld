FROM java:openjdk-8-jdk

# Define environment variables.
ENV MULE_HOME=/opt/mule MULE_VERSION=4.4.0 MULE_MD5=1d80bbd88bb0d65006282817dd551743 TZ=Europe/Madrid MULE_USER=mule

# SSL Cert for downloading mule zip
RUN apk --no-cache update apk --no-cache upgrade apk --no-cache add ca-certificates update-ca-certificates apk --no-cache add openssl apk add --update tzdata rm -rf /var/cache/apk/*

RUN adduser -D -g "" ${MULE_USER} ${MULE_USER}

RUN echo ${TZ} > /etc/timezone

USER ${MULE_USER}

# Mule CE
#RUN cd ~ && wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz \
#	&& tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz \
#	&& rm -rf ~/mule-standalone-${MULE_VERSION}.tar.gz \
#	&& cp -r ~/mule-standalone-${MULE_VERSION}/* /opt/mule/ \
#	&& rm -rf ~/mule-standalone-${MULE_VERSION}

# Mule EE
RUN cd ~ && wget https://s3.amazonaws.com/new-mule-artifacts/mule-ee-distribution-standalone-4.4.0.tar.gz \
	&& tar xvzf ~/mule-ee-distribution-standalone-${MULE_VERSION}.tar.gz \
	&& rm -rf ~/mule-ee-distribution-standalone-${MULE_VERSION}.tar.gz \
	&& cp -r ~/mule-ee-distribution-standalone-${MULE_VERSION}/* /opt/mule/ \
	&& rm -rf ~/mule-ee-distribution-standalone-${MULE_VERSION}

# To use MuleSoft EE 
COPY /opt/muleconfig/conf/muleLicenseKey.lic ${MULE_HOME}/conf/muleLicenseKey.lic

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Define working directory.
WORKDIR ${MULE_HOME}

CMD [ "/opt/mule/bin/mule"]

# Default http port
EXPOSE 8081
