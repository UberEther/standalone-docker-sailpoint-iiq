#!/bin/bash

SCRIPT_FULLPATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")
SCRIPT_NAME=$(basename "$SCRIPT_FULLPATH")
IIQ_FOLDER=$(realpath "${SCRIPT_DIR}"/..)

# Default SP_HOME if not set...
SP_HOME="${SP_HOME:-/ue/iiq/tomcat/webapps/ue}"
MYSQL_HOST="localhost"

CREATION_SCRIPTS=(
        "${SP_HOME}/database/create_identityiq_tables-8.0.mysql"
    )

UPDATE_SCRIPTS=(
        "${SP_HOME}/WEB-INF/database/upgrade_identityiq_tables.mysql"
        "${SP_HOME}/WEB-INF/database/add_identityiq_extensions.mysql"
    )

if [ ! -x "$(command -v mysql)" ]; then
    echo "#### ERROR: mysql not found on path - aborting"
    exit 98;
fi

if [ ! -f "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" ]; then
    echo "#### No permissions on IIQ - Aborting"
    exit 98
fi

if [ ! -x "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" ]; then
    echo "#### Setting execute permissions on iiq"
    chmod +x "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" || onFailure
fi

set -o pipefail
function onFailure {
    echo "###############################"
    echo "#### ERROR: Unexpected failure in command - review logs above"
    exit 99
}

function onExit {
    echo "#### `date`"
    echo "###############################"
}
trap onExit EXIT

SCRIPT_REALPATH=`realpath $0`
echo "###############################"
echo "#### Creating IIQ database"
echo "#### `md5sum ${SCRIPT_REALPATH}`"
echo "#### `date`"
echo "###############################"

printf "#### Waiting for MySQL"
until [ "$(mysql -h"${MYSQL_HOST}" -B -N -e "select 1;" 2>&1)" == "1" ]; do
    printf "."
    sleep 1
done
printf "\n"

echo "#### Checking if DB exists"
DBS=`mysql -h"${MYSQL_HOST}" -B -N -e "SHOW DATABASES LIKE 'identityiq';" 2>&1`
if [ "$DBS" != "identityiq"  ]; then
    #################### CREATE DB ####################
    echo "#### No identityiq DB found - running creation scripts"

    for SCRIPT_FILE in "${CREATION_SCRIPTS[@]}"; do
        echo "###############################"
        if [ ! -f "${SCRIPT_FILE}" ]; then
			echo "#### ERROR: File not found: ${SCRIPT_FILE}"
           	exit 1
        fi
        echo "#### `md5sum ${SCRIPT_FILE}`"
        mysql -h"${MYSQL_HOST}" < "${SCRIPT_FILE}" || onFailure
    done
fi

#################### EXISTING DB ####################
SYSTEM_VER=`mysql -h"${MYSQL_HOST}" -B -N -e "SELECT system_version FROM identityiq.spt_database_version WHERE name = 'main'" 2>&1`
SCHEMA_VER=`mysql -h"${MYSQL_HOST}" -B -N -e "SELECT schema_version FROM identityiq.spt_database_version WHERE name = 'main'" 2>&1`
echo "#### Existing DB found - SystemVer: ${SYSTEM_VER}   SchemaVer: ${SCHEMA_VER}"

#################### UPDATING DB SCHEMA ####################
echo "#### Generating DB Schema for Extended Attributes"
runuser -s /bin/bash -c "JAVA_HOME=${IIQ_FOLDER}/java ${SP_HOME}/WEB-INF/bin/iiq extendedSchema" || onFailure

#################### UPDATING DB SCHEMA ####################
echo "#### Updating DB Schema - Ignores DDL errors so manually review"
for SCRIPT_FILE in "${UPDATE_SCRIPTS[@]}"; do
    echo "###############################"
    if [ ! -f "${SCRIPT_FILE}" ]; then
		echo "#### ERROR: File not found: ${SCRIPT_FILE}"
        exit 1
    fi
    echo "#### `md5sum ${SCRIPT_FILE}`"
    mysql -f -h"${MYSQL_HOST}" < "${SCRIPT_FILE}" || onFailure
done

echo "###############################"
echo "#### DB Creation Complete"
echo "#### Manually review DB updates for unexpected DDL errors"

exit 0
