FROM mysql:5
MAINTAINER Matt Topper <matt@uberether.com>

ENV MYSQL_ROOT_PASSWORD=root

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
# Create a .my.cnf so we don't embed passwords into CLI arguments
#
RUN touch /root/.my.cnf && \
    chmod 600 /root/.my.cnf && \
    chown root:root /root/.my.cnf && \
    echo "[client]" >> /root/.my.cnf && \
    echo "password=root" >> /root/.my.cnf

#
# Sailpoint required settings
#
# 1) sql_mode setting must not contain 'STRICT_TRANS_TABLES'
# Required per SP docs
RUN sed -i 's~,STRICT_TRANS_TABLES~~' /etc/mysql/my.cnf && \
    sed -i 's~,STRICT_TRANS_TABLES~~' /etc/mysql/my.cnf && \
    echo "[mysqld]" >> /etc/mysql/my.cnf && \
    echo "innodb_large_prefix = 1" >> /etc/mysql/my.cnf && \
    echo "innodb_file_per_table = 1" >> /etc/mysql/my.cnf

# Recommended per SP docs
RUN echo "innodb_file_format = BARRACUDA" >> /etc/mysql/my.cnf && \
    echo "innodb_file_format_max = BARRACUDA" >> /etc/mysql/my.cnf && \
    echo "innodb_log_file_size = 64M" >> /etc/mysql/my.cnf

# Recommended by other users on Compass
RUN echo "max_allowed_packet = 256M" >> /etc/mysql/my.cnf && \
    echo "innodb_buffer_pool_size = 256M" >> /etc/mysql/my.cnf && \
    echo "innodb_log_buffer_size = 8M" >> /etc/mysql/my.cnf && \
    echo "innodb_lock_wait_timeout = 50" >> /etc/mysql/my.cnf && \
    echo "server-id=1" >> /etc/mysql/my.cnf && \
    echo "sql_mode=NO_ENGINE_SUBSTITUTION" >> /etc/mysql/my.cnf

#
# CREATE FAKE TOMCAT FOLDER FOR ue FOLDER
#
RUN mkdir -m 6750 /ue/iiq/tomcat && \
    mkdir -m 6750 /ue/iiq/tomcat/webapps && \
    mkdir -m 6750 /ue/iiq/tomcat/webapps/ue && \
    ln -sfT /ue/iiq/tomcat/webapps/ue/WEB-INF /ue/iiq/WEB-INF

#
# INSTALLING JAVA FOR BUILDING SCHEMA EXTENSIONS
#
RUN set -ex; \
# deal with slim variants not having man page directories (which causes "update-alternatives" to fail)
	if [ ! -d /usr/share/man/man1 ]; then \
		mkdir -p /usr/share/man/man1; \
	fi; \
	\
	apt-get update; \
	apt-get install -y \
		openjdk-8-jre-headless \
		ca-certificates-java \
		; \
	rm -rf /var/lib/apt/lists/*; \
	\
	# verify that "docker-java-home" returns what we expect
	[ "$(readlink -f "$JAVA_HOME")" = "$(docker-java-home)" ]; \
	\
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
	update-alternatives --query java | grep -q 'Status: manual'

# see CA_CERTIFICATES_JAVA_VERSION notes above
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

#
# Specify our exposed resources
#
VOLUME [ "/ue/iiq/tomcat/webapps/ue", "/ue/iiq/scripts" ]
