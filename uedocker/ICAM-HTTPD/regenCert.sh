#!/bin/bash
#
# This script functions from within GitBash
#
# Note: Ensure your OpenSSL is working correctly and finds the config file!
#

CERTNAME="local-dev"

set -o pipefail
function onFailure {
    echo "###############################"
    echo "#### ERROR: Unexpected failure in command - review logs above"
    echo "#### `date`"
    echo "###############################"
    exit 99
}

echo "###############################"
echo "#### Generating new SSL Cert"
echo "#### `date`"
echo "###############################"

if [ -f "${CERTNAME}.cer" ]; then
    cp "${CERTNAME}.cer" "${CERTNAME}.cer.bak" || onFailure
fi
if [ -f "${CERTNAME}.key" ]; then
    cp "${CERTNAME}.key" "${CERTNAME}.key.bak" || onFailure
fi

# http://superuser.com/questions/226192/openssl-without-prompt
# http://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl
# http://stackoverflow.com/questions/6194236/openssl-version-v3-with-subject-alternative-name
# https://mta.openssl.org/pipermail/openssl-users/2016-January/002764.html
openssl req \
    -new \
    -newkey rsa:2048 \
    -days 3652 \
    -nodes \
    -sha384 \
    -subj "/O=DEV USE ONLY/CN=*.icam.local" \
    -keyout "${CERTNAME}.key" \
    -out "${CERTNAME}.csr" \
    || onFailure

EXT_FILE=`mktemp`
trap 'rm -f "${EXT_FILE}"; rm -f "${CERTNAME}.csr";' EXIT
chmod 660 "${EXT_FILE}" || onFailure

printf '[SAN]\nsubjectAltName=DNS:*.icam.local\n' > "${EXT_FILE}"
#cat "${EXT_FILE}"

openssl x509 \
    -req \
    -in "${CERTNAME}.csr" \
    -signkey "${CERTNAME}.key" \
    -days 3652 \
    -sha384 \
    -extensions SAN \
    -extfile "${EXT_FILE}" \
    -out "${CERTNAME}.cer" \
    || onFailure

openssl verify "${CERTNAME}.cer" || onFailure
openssl x509 -text -in "${CERTNAME}.cer" || onFailure

echo "###############################"
echo "#### New SSL Cert Generated"
echo "#### `date`"
echo "###############################"
