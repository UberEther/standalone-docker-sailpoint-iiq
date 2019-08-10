#!/bin/bash
#
# Stops and cleans current environment and rebuilds IIQ
#

#shopt -s extglob

# @todo Work out way to detect it...
IIQ_VERSION=8.0

WAR_PATH="./ue#local-dev-${IIQ_VERSION}.war"
if [ ! -f "${WAR_PATH}" ]; then
    WAR_PATH="../ssb/release/ue#local-dev-${IIQ_VERSION}.war"
fi

set -o pipefail
function onFailure {
    echo "###############################"
    echo "#### Unexpected failure in command - review logs above"
    exit 99
}

echo "#### Stopping Docker"
docker-compose stop app || onFailure

START_BOOTSTRAP="$(date)"

echo "#### Cleaning up old IIQ app"
$(cd volumes/app-ue && find . ! -name '.gitignore' -type f -exec rm -rf {} +)

if [ "$1" == "build" ]; then
    echo "#### Running build"
    rm "${WAR_PATH}"
    if [ -f "${WAR_PATH}" ]; then
        echo "#### Unable to delete old war"
        onFailure
    fi
    pushd ../ssb
    START_BUILD="$(date)"
    ./build.sh
    END_BUILD="$(date)"
    popd
    if [ ! -f "${WAR_PATH}" ]; then
        echo "#### Unable to find old war after build: ${WAR_PATH}"
        onFailure
    fi
fi

echo "#### Unzipping release"
unzip -q "${WAR_PATH}" -d volumes/app-ue || onFailure

echo "#### Creating new containers"
START_CREATE="$(date)"
./create.sh || onFailure
END_CREATE="$(date)"

echo "####"
echo "####"
echo "#### Start bootstrap: ${START_BOOTSTRAP}"
echo "#### (purge old build)"
echo "#### Start build:     ${START_BUILD}"
echo "#### End build:       ${END_BUILD}"
echo "#### (unzip war)"
echo "#### Start create:    ${START_CREATE}"
echo "#### End create:      ${END_CREATE}"
echo "#### End bootstrap:   ${END_CREATE}"
echo "####"
echo "####"
