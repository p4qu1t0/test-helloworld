FROM java:openjdk-8-jdk

ENV MULE_HOME /opt/mule

ADD mule-standalone-4.3.0.zip /opt
ADD mule-hello.jar /opt

RUN set -x \
		&& cd /opt \
		&& unzip mule-standalone-4.3.0.zip \
		&& mv mule-standalone-4.3.0 mule
		
WORKDIR $MULE_HOME
VOLUME $MULE_HOME/apps
VOLUME $MULE_HOME/conf
VOLUME $MULE_HOME/domains
VOLUME $MULE_HOME/logs

#Copy and install license
#CMD echo "----- Copy and install license -----"
#COPY licenseKeyStore $MULE_HOME/conf/

# RUN $MULE_HOME/bin/mule -installLicense $MULE_HOME/conf/licenseKeyStore

#Check if Mule License installed
#RUN ls -ltr $MULE_HOME/conf/
#CMD echo "---- License installed ! ----"

#Copy and deploy mule application in runtime
CMD echo "---- Deploying mule application in runtime ! ----"
COPY mule-hello.jar $MULE_HOME/apps/
RUN ls -ltr $MULE_HOME/apps/

# HTTP Service Port
# Expose the necessary port ranges as required by the Mule Apps
EXPOSE 8081-8091
EXPOSE 9000
EXPOSE 9082

# Mule remote debugger
EXPOSE 5000

# Mule JMX port (must match Mule config file)
EXPOSE 1098

# Mule MMC agent port
EXPOSE 7777

# AMC agent port
EXPOSE 9997

# Start Mule runtime
CMD echo "---- Start Mule runtime ----"
ENTRYPOINT ["./bin/mule"]
