FROM java:openjdk-8-jdk

# Define environment variables.
ENV MULE_HOME=/opt/mule 
ENV MULE_VERSION=4.4.0 
ENV MULE_MD5=84f9f9bd23c71b248f295d894e41fb01
ENV TZ=Europe/Madrid
ENV MULE_USER=mule
ARG JENKINS_WORKSPACE
ARG MULE_APP

RUN echo "$PWD"

WORKDIR ${MULE_HOME}

# SSL Cert for downloading mule zip
#RUN apk --no-cache update apk --no-cache upgrade apk --no-cache add ca-certificates update-ca-certificates apk --no-cache add openssl apk add --update tzdata rm -rf /var/cache/apk/*

RUN useradd -ms ${MULE_HOME} ${MULE_USER}
RUN mkdir -p ${MULE_HOME}
RUN chown -R ${MULE_USER}:${MULE_USER} ${MULE_HOME}
RUN chmod 755 ${MULE_HOME}

USER ${MULE_USER}

#RUN apt-get update

RUN mkdir -p ./mule-standalone-${MULE_VERSION}
RUN chown -R ${MULE_USER}:${MULE_USER} ${MULE_HOME}/mule-standalone-${MULE_VERSION}

#RUN chown -R ${MULE_USER}:${MULE_USER} /etc/timezone
#RUN chmod 755 /etc/timezone
USER root
CMD echo ${TZ} > /etc/timezone
USER ${MULE_USER}

# Checksum
#RUN cd ~ && wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz echo "${MULE_MD5}  mule-standalone-${MULE_VERSION}.tar.gz" | md5sum -c cd /opt tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz rm ~/mule-standalone-${MULE_VERSION}.tar.gz
RUN cd ${MULE_HOME} && wget https://repository.mulesoft.org/nexus/service/local/repositories/releases/content/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz
CMD echo "${MULE_MD5} mule-standalone-${MULE_VERSION}.tar.gz"

#RUN set -x \
#		&& cd ${MULE_HOME} \
#		&& tar xvzf ${MULE_HOME}/mule-standalone-${MULE_VERSION}.tar.gz \
#		&& mv ${MULE_HOME}/mule-standalone-${MULE_VERSION} ${MULE_HOME}

RUN tar xvzf ${MULE_HOME}/mule-standalone-${MULE_VERSION}.tar.gz
RUN ln -s ${MULE_HOME}/mule-standalone-${MULE_VERSION}/ ${MULE_HOME}
RUN rm ${MULE_HOME}/mule-standalone-${MULE_VERSION}.tar.gz

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# To use MuleSoft EE 
CMD echo "----- Copy and install license -----"
WORKDIR ${JENKINS_WORKSPACE}
COPY conf/muleLicenseKey.lic ${MULE_HOME}/conf/
#Copy and deploy mule application in runtime
ADD target/${MULE_APP} ${MULE_HOME}/apps/

WORKDIR ${MULE_HOME}
RUN ${MULE_HOME}/bin/mule -installLicense ${MULE_HOME}/conf/muleLicenseKey.lic

#Check if Mule License installed
#RUN ls -ltr $MULE_HOME/conf/
#CMD echo "---- License installed ! ----"

#CMD [ "/opt/mule/bin/mule"]
ENTRYPOINT ["${MULE_HOME}/bin/mule"]

# Default http port
EXPOSE 8081-8082
EXPOSE 9000
EXPOSE 9082

# Mule remote debugger
EXPOSE 5000

# Mule JMX port (must match Mule config file)
EXPOSE 1098

# Mule MMC agent port
EXPOSE 7777
