#!/bin/bash
#
# Stops and cleans current environment and rebuilds IIQ
#

#shopt -s extglob

PROPERTIES_FILE="../ssb/envconfig/local-dev/build.properties"
IIQ_VERSION=$(grep "IIQVersion" ${PROPERTIES_FILE} | cut -d '=' -f2)
PATCH_LEVEL=$(grep "IIQPatchLevel" ${PROPERTIES_FILE} | cut -d '=' -f2)

if [[ ! -z "${PATCH_LEVEL}" ]]
then
    IIQ_VERSION=$(echo ${IIQ_VERSION}${PATCH_LEVEL} | xargs)
else
    IIQ_VERSION=$(echo ${IIQ_VERSION} | xargs)
fi

WAR_PATH="../ssb/release/ue#local-dev-${IIQ_VERSION}.war"

if [ ! -z "$2" ]; then
    WAR_PATH="../ssb/release/ue#$2-${IIQ_VERSION}.war"
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
    START_BUILD="$2 $(date)"
    if [ ! -z "$2" ]
    then
        echo "#### Running build [$2]"
        ./build.sh -Due.env="$2"
    else
        echo "#### Running build [default]"
    ./build.sh
    fi
    END_BUILD="$(date)"
    popd
    if [ ! -f "${WAR_PATH}" ]; then
        echo "#### Unable to find old war after build: ${WAR_PATH}"
        onFailure
    fi
fi

echo "#### Unzipping release"
unzip -q "${WAR_PATH}" -d volumes/app-ue || onFailure

echo '#### Setting execute permissions on iiq console'
chmod +x volumes/app-ue/WEB-INF/bin/iiq

echo "#### Creating new containers"
START_CREATE="$(date)"
./create.sh || onFailure
END_CREATE="$(date)"
END_BOOTSTRAP="$(date)"

echo "####"
echo "####"
echo "#### Start bootstrap: ${START_BOOTSTRAP}"
echo "#### (purge old build)"
echo "#### Start build:     ${START_BUILD}"
echo "#### End build:       ${END_BUILD}"
echo "#### (unzip war)"
echo "#### Start create:    ${START_CREATE}"
echo "#### End create:      ${END_CREATE}"
echo "#### End bootstrap:   ${END_BOOTSTRAP}"
echo "####"
echo "####"
