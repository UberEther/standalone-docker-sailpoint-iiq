FROM httpd:2.4

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
# CREATE CORE DIRECTORY STRUCTURE
#
RUN mkdir -m 6750 /ue               && umask 0027 /ue               && chown root:identityiq       /ue               && \
    mkdir -m 6770 /ue/backups       && umask 0007 /ue/backups       && chown root:root             /ue/backups       && \
    mkdir -m 6750 /ue/certs         && umask 0027 /ue/certs         && chown root:identityiq       /ue/certs         && \
    mkdir -m 6750 /ue/certs/private && umask 0027 /ue/certs/private && chown root:identityiq       /ue/certs/private && \
    mkdir -m 6750 /ue/conf          && umask 0027 /ue/conf          && chown root:identityiq       /ue/conf          && \
    mkdir -m 6750 /ue/logs          && umask 0027 /ue/logs          && chown root:identityiq       /ue/logs          && \
    mkdir -m 6770 /ue/logs/tomcat   && umask 0007 /ue/logs/tomcat   && chown identityiq:identityiq /ue/logs/tomcat   && \
    mkdir -m 6770 /ue/logs/httpd    && umask 0007 /ue/logs/httpd    && chown root:root             /ue/logs/httpd    && \
    mkdir -m 6770 /ue/logs/scripts  && umask 0007 /ue/logs/scripts  && chown root:root             /ue/logs/scripts  && \
    mkdir -m 6750 /ue/iiq           && umask 0027 /ue/iiq           && chown root:identityiq       /ue/iiq           && \
    mkdir -m 6750 /ue/iiq/scripts   && umask 0027 /ue/iiq/scripts   && chown root:identityiq       /ue/iiq/scripts

#
# LINK RESOURCES INTO DIRECTORY STRUCTURE
#
RUN ln -s /usr/local/apache2 /ue/iiq/httpd

#
# Copy local resources
#
COPY httpd.conf /ue/iiq/httpd/conf/
COPY ue-httpd-settings.conf /ue/iiq/httpd/conf/
COPY dev.icam.local.cer /ue/certs/
COPY dev.icam.local.key /ue/certs/private/
RUN chown root:root /ue/certs/private/dev.icam.local.key

#
# Specify our exposed resources
#
EXPOSE 443
VOLUME [ "/ue/logs/httpd" ]
