FROM java:openjdk-8-jdk

# Define environment variables.
ENV MULE_HOME=/opt/mule 
ENV MULE_VERSION=4.4.0 
ENV MULE_MD5=84f9f9bd23c71b248f295d894e41fb01
ENV TZ=Europe/Madrid
ENV MULE_USER=mule

# SSL Cert for downloading mule zip
#RUN apk --no-cache update apk --no-cache upgrade apk --no-cache add ca-certificates update-ca-certificates apk --no-cache add openssl apk add --update tzdata rm -rf /var/cache/apk/*

RUN useradd -ms ${MULE_HOME} ${MULE_USER}
RUN mkdir -p ${MULE_HOME}
RUN chown -R ${MULE_USER}:${MULE_USER} ${MULE_HOME}
RUN chmod 755 ${MULE_HOME}

USER ${MULE_USER}

RUN apt-get update

RUN mkdir -p /opt/mule/mule-standalone-${MULE_VERSION} ln /opt/mule/mule-standalone-${MULE_VERSION} ${MULE_HOME} chown ${MULE_USER}:${MULE_USER} /opt/mule*

RUN echo ${TZ} > /etc/timezone

# Checksum
#RUN cd ~ && wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz echo "${MULE_MD5}  mule-standalone-${MULE_VERSION}.tar.gz" | md5sum -c cd /opt tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz rm ~/mule-standalone-${MULE_VERSION}.tar.gz
RUN cd ~ && wget https://repository.mulesoft.org/nexus/service/local/repositories/releases/content/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz echo "${MULE_MD5}  mule-standalone-${MULE_VERSION}.tar.gz" | md5sum -c cd /opt tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz rm ~/mule-standalone-${MULE_VERSION}.tar.gz

# To use MuleSoft EE 
COPY /opt/mule/conf/muleLicenseKey.lic /opt/mule/conf/muleLicenseKey.lic

#Copy and deploy mule application in runtime
COPY /opt/mule/app/mule-hello.jar $MULE_HOME/apps/

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Define working directory.
WORKDIR ${MULE_HOME}

#CMD [ "/opt/mule/bin/mule"]
ENTRYPOINT ["./bin/mule"]

# Default http port
EXPOSE 8081
