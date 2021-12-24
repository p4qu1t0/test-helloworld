FROM java:openjdk-8-jdk

# Define environment variables.
ENV MULE_HOME=/opt/mule 
ENV MULE_VERSION=4.4.0 
ENV MULE_MD5=84f9f9bd23c71b248f295d894e41fb01
ENV TZ=Europe/Madrid
ENV MULE_USER=mule
ARG JENKINS_WORKSPACE
ARG MULE_APP

# SSL Cert for downloading mule zip
#RUN apk --no-cache update apk --no-cache upgrade apk --no-cache add ca-certificates update-ca-certificates apk --no-cache add openssl apk add --update tzdata rm -rf /var/cache/apk/*

RUN useradd -ms / ${MULE_USER}
RUN mkdir -p ${MULE_HOME}
RUN chown -R ${MULE_USER}:${MULE_USER} ${MULE_HOME}
RUN chmod 755 ${MULE_HOME}
RUN chown -R ${MULE_USER}:${MULE_USER} ~
RUN chmod 755 ~

USER ${MULE_USER}

#RUN apt-get update

#RUN mkdir -p ./mule-standalone-${MULE_VERSION}
#RUN chown -R ${MULE_USER}:${MULE_USER} ${MULE_HOME}/mule-standalone-${MULE_VERSION}

#RUN chown -R ${MULE_USER}:${MULE_USER} /etc/timezone
#RUN chmod 755 /etc/timezone
USER root
CMD echo ${TZ} > /etc/timezone
USER ${MULE_USER}

# Mule CE
#RUN cd ~ && wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz \
#	&& tar xvzf ~/mule-standalone-${MULE_VERSION}.tar.gz \
#	&& rm -rf ~/mule-standalone-${MULE_VERSION}.tar.gz \
#	&& cp -r ~/mule-standalone-${MULE_VERSION}/* /opt/mule/ \
#	&& rm -rf ~/mule-standalone-${MULE_VERSION}

# Mule EE
USER root
RUN cd ~ && wget https://s3.amazonaws.com/new-mule-artifacts/mule-ee-distribution-standalone-4.4.0.tar.gz
CMD echo "${MULE_MD5} ~/mule-ee-distribution-standalone-${MULE_VERSION}.tar.gz"
RUN tar xvzf ~/mule-ee-distribution-standalone-${MULE_VERSION}.tar.gz
RUN ln -s ~/mule-ee-distribution-standalone-${MULE_VERSION} ${MULE_HOME}
RUN rm -rf ~/mule-ee-distribution-standalone-${MULE_VERSION}


# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

WORKDIR ${MULE_HOME}
RUN echo "$PWD"

# To use MuleSoft EE 
CMD echo "----- Copy and install license -----"

#Copy license
COPY conf/muleLicenseKey.lic ${MULE_HOME}/conf/
#RUN cd ${MULE_HOME} && echo "$PWD"
RUN echo "$PWD"

#Copy and deploy mule application in runtime
ADD target/${MULE_APP} ${MULE_HOME}/apps/

RUN ${MULE_HOME}/bin/mule -installLicense ${MULE_HOME}/conf/muleLicenseKey.lic

#Check if Mule License installed
RUN ls -ltr $MULE_HOME/conf/
#CMD echo "---- License installed ! ----"

#USER root
#CMD [ "/bin/mule"]
ENTRYPOINT ["./bin/mule"]

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
