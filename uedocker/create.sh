#!/bin/bash
#
# Drops any existing volumes and recreates the whole environment...
#
# Scripts run via source because the execute permissions may not be set
#

set -o pipefail
function onFailure {
    echo "###############################"
    echo "#### Unexpected failure in command - review logs above"
    exit 99
}

WINPTY_BIN="$(which winpty)"

echo "#### Build Docker Containers"
docker-compose build || onFailure

echo "#### Stop Docker"
docker-compose down -v || onFailure

echo "#### Clean logs"
rm -f volumes/app-logs/*.log* || onFailure
rm -f volumes/app-logs/*.txt || onFailure
rm -f volumes/web-logs/*.log || onFailure

echo "#### Start DB container"
docker-compose up -d db || onFailure

echo "#### Run DB Script"
${WINPTY_BIN} docker exec -it --user root uedocker_db_1 bash -c 'source /ue/iiq/scripts/iiq-createDb.sh' || onFailure

echo "#### Start All containers"
docker-compose up -d || onFailure

echo "#### Run config import"
${WINPTY_BIN} docker exec -it --user root uedocker_app_1 bash -c 'source /ue/iiq/scripts/iiq-loadXml.sh create' || onFailure
