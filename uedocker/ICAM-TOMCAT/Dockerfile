FROM tomcat:9.0-jre8
MAINTAINER Michael Samblanet <samblanetm@uberether.com>

#
# SETUP TIME ZONE
#
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#
# CREATE CORE USERS
#
RUN groupadd identityiq && \
    useradd -M -s /bin/nologin -g identityiq -d /home/identityiq identityiq && \
    \
    groupadd apache && \
    useradd -M -s /bin/nologin -g apache -d /home/apache apache

#
# FIX PARENT IMAGE'S OWNERSHIPS SO WE CAN RUN AS OUR USER
#
RUN chown -R identityiq:identityiq /usr/local/tomcat

#
# CREATE CORE DIRECTORY STRUCTURE
#
RUN mkdir -m 6750 /ue               && umask 0027 /ue               && chown root:identityiq      /ue               && \
    mkdir -m 6770 /ue/backups       && umask 0007 /ue/backups       && chown root:root           /ue/backups       && \
    mkdir -m 6750 /ue/certs         && umask 0027 /ue/certs         && chown root:identityiq      /ue/certs         && \
    mkdir -m 6750 /ue/certs/private && umask 0027 /ue/certs/private && chown root:identityiq      /ue/certs/private && \
    mkdir -m 6750 /ue/conf          && umask 0027 /ue/conf          && chown root:identityiq      /ue/conf          && \
    mkdir -m 6750 /ue/logs          && umask 0027 /ue/logs          && chown root:identityiq      /ue/logs          && \
    mkdir -m 6770 /ue/logs/tomcat   && umask 0007 /ue/logs/tomcat   && chown identityiq:identityiq /ue/logs/tomcat   && \
    mkdir -m 6770 /ue/logs/httpd    && umask 0007 /ue/logs/httpd    && chown root:root           /ue/logs/httpd    && \
    mkdir -m 6770 /ue/logs/scripts  && umask 0007 /ue/logs/scripts  && chown root:root           /ue/logs/scripts  && \
    mkdir -m 6750 /ue/iiq           && umask 0027 /ue/iiq           && chown root:identityiq      /ue/iiq           && \
    mkdir -m 6750 /ue/iiq/scripts   && umask 0027 /ue/iiq/scripts   && chown root:identityiq      /ue/iiq/scripts

#
# LINK RESOURCES INTO DIRECTORY STRUCTURE
#
RUN ln -sf /usr/local/tomcat /ue/iiq/tomcat && \
    rm -rf /usr/local/tomcat/logs && \
    ln -sfT /ue/logs/tomcat /usr/local/tomcat/logs && \
    mkdir /ue/iiq/tomcat/webapps/ue && \
    ln -sfT /usr/lib/jvm/java-8-openjdk-amd64 /ue/java && \
    ln -sfT /usr/lib/jvm/java-8-openjdk-amd64 /ue/iiq/java && \
    ln -sfT /ue/iiq/tomcat/webapps/ue/WEB-INF /ue/iiq/WEB-INF

#
# ADD OUR DEV CERTS TO THE JAVA TRUST CHAIN
#
ADD dev.icam.local.cer .
RUN keytool -importcert -noprompt -trustcacerts -alias 'dev.icam.local' -file dev.icam.local.cer -keystore /etc/ssl/certs/java/cacerts -storepass changeit -v && \
    rm dev.icam.local.cer

#
# Add the IIQ keys in
#
ADD iiq.cfg /ue/certs/private
ADD iiq.dat /ue/certs/private
RUN chmod 640             /ue/certs/private/iiq.cfg /ue/certs/private/iiq.dat && \
    chown root:identityiq /ue/certs/private/iiq.cfg /ue/certs/private/iiq.dat

#
# SET URIEncoding for all Tomcat connectors (per IIQ install guide)
# and update redirectPort to 443 (since we are reverse proxied)
#
RUN /bin/sed -i 's~redirectPort="8443"~redirectPort="443"~' /ue/iiq/tomcat/conf/server.xml && \
    /bin/sed -i 's~<Connector ~<Connector URIEncoding="UTF-8" ~' /ue/iiq/tomcat/conf/server.xml

#
# Environment to control Tomcat's behavior
# See https://community.sailpoint.com/docs/DOC-6252
# Memory was reduced for use in our sandbox
#

#
# Enable one of these two lines for JMX options to enable or disable the Java debugger (generally keep disabled)
#
ENV JAVA_DEBUG_OPTS=""
#ENV JAVA_DEBUG_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"

#
# Enable one of these two lines for JMX options to enable or disable the JMX listener for debugging (generally keep disabled)
#
ENV JMX_OPTS=""
#ENV JMX_OPTS="-XX:+DisableAttachMechanism -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=dev.icam.local -Dcom.sun.management.jmxremote.port=8001 -Dcom.sun.management.jmxremote.rmi.port=8001"
# https://stackoverflow.com/questions/856881/how-to-activate-jmx-on-my-jvm-for-access-with-jconsole
# https://stackoverflow.com/questions/20884353/why-java-opens-3-ports-when-jmx-is-configured

ENV CATALINA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC ${JAVA_DEBUG_OPTS} ${JMX_OPTS} \
                   -Dcom.sun.jndi.ldap.connect.pool.timeout=3000 \
                   -Dcom.sun.jndi.ldap.connect.pool.protocol='plain ssl' \
                   -Dcom.sun.jndi.ldap.connect.pool.authentication='none simple DIGEST-MD5' \
                   -Dsailpoint.debugPages=true \
                   -Diiq.hostname=dev-iiq.icam.local \
                  "
#
# Specify our exposed resources
#
EXPOSE 8080
EXPOSE 8000
EXPOSE 8001
VOLUME [ "/ue/logs/tomcat", "/usr/local/tomcat/webapps/ue", "/ue/iiq/scripts" ]

#
# Override the run user for tomcat (do we just all this or just the user?)
#
WORKDIR $CATALINA_HOME
USER identityiq
CMD ["catalina.sh", "run"]
