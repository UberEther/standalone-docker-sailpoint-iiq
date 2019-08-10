#!/bin/bash

cp local-dev.cer dev.icam.local.cer
cp local-dev.key dev.icam.local.key

cp local-dev.cer ../ICAM-TOMCAT/dev.icam.local.cer

cp local-dev.cer ../ICAM-LDAP/certs/ca.crt
cp local-dev.cer ../ICAM-LDAP/certs/ldap.crt
cp local-dev.key ../ICAM-LDAP/certs/ldap.key

cp local-dev.cer ../ICAM-SAML/cert/saml.crt
cp local-dev.key ../ICAM-SAML/cert/saml.key
