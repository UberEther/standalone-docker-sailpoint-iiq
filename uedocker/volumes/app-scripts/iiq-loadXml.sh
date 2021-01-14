#!/bin/bash
#
# This script functions from within GitBash
#
# Note: Ensure your OpenSSL is working correctly and finds the config file!
#

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

SCRIPT_FULLPATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")
SCRIPT_NAME=$(basename "$SCRIPT_FULLPATH")
IIQ_FOLDER=$(realpath "${SCRIPT_DIR}"/..)

SP_HOME="${SP_HOME:-/ue/iiq/tomcat/webapps/ue}"
BACKUP_CLASSES=(
    "AccountGroup" "ActivityDataSource" "Application" "ApplicationActivity" "AuditConfig"
    "BatchRequest" "Category" "Capability" "CertificationDefinition" "CertificationGroup"
    "Configuration" "CorrelationConfig" "Custom" "DashboardContent" "DashboardLayout" "DatabaseVersion" "Dictionary"
    "DynamicScope" "EmailTemplate" "Form" "FullTextIndex" "GroupFactory" "GroupDefinition" "GroupIndex"
    "IdentityTrigger" "IntegrationConfig"
    "JasperResult" "JasperTemplate" "LocalizedAttribute" "ManagedAttribute" "MessageTemplate" "MiningConfig" "MitigationExpiration"
    "ObjectConfig" "PasswordPolicy" "Policy" "PolicyViolation" "Process" "ProcessLog" "Profile" "ProvisioningRequest"
    "QuickLink" "QuickLinkOptions" "Request" "RequestDefinition" "ResourceEvent" "RightConfig" "RoleChangeEvent" "RoleIndex"
    "RoleMetadata" "RoleMiningResult" "RoleScorecard" "Rule" "RuleRegistry" "Scope" "Scorecard" "ScoreConfig" "SPRight"
    "ServiceDefinition" "ServiceStatus" "Server" "SyslogEvent" "Target" "TargetAssociation" "TargetSource" "TaskDefinition"
    "TaskSchedule" "TimePeriod" "UIConfig" "Widget" "Workflow" "WorkflowRegistry"
    "WorkflowTestSuite"
)
LOG_FOLDER="/ue/logs/tomcat"
BACKUP_FOLDER="/ue/backups"
BACKUP_FILE="${BACKUP_FOLDER}/$(basename $SCRIPT_FULLPATH)-$(date +%Y-%m-%d-%H.%M.%S).xml"

if [ ! -f "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" ]; then
    echo "#### No permissions on IIQ - Aborting"
    exit 98
fi

set -o pipefail
function onFailure {
    echo "###############################"
    echo "#### ERROR: Unexpected failure in command - review logs above"
    exit 99
}

export LOGFILE="${LOG_FOLDER}/$(basename $SCRIPT_FULLPATH)-$(date +%Y-%m-%d-%H.%M.%S).log"
if [ ! -d "$(dirname ${LOGFILE})" ]; then
    echo "Log path not found: $(dirname ${LOGFILE})"
    echo "Was $(dirname $SCRIPT_FULLPATH)/ue-bootstrap.sh run?"
    exit 96
fi

# For all commands from here on, redirects stdout and stderr to tee
exec > >(tee -a "${LOGFILE}") 2>&1

function onExit {
    echo "#### `date`"
    echo "#### Log File: ${LOGFILE}"
    echo "###############################"
}
trap onExit EXIT

echo "###############################"
echo "#### Loading IIQ Configuration"
echo "#### `md5sum ${SCRIPT_FULLPATH}`"
echo "###############################"

if [ ! -x "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" ]; then
    echo "#### Setting execute permissions on iiq"
    chmod +x "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" || onFailure
fi

echo "#### Hashes of new configuration"
find "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/config" -type f -exec md5sum {} \; | sort -k 2 || onFailure

echo "#### Backing up existing config to ${BACKUP_FILE}"
echo "#### and loading init.xml"
echo
touch "${BACKUP_FILE}" || onFailure
BACKUP_TMP_FILE=`mktemp`
SCRIPT_FILE=`mktemp`
trap 'rm -f "${BACKUP_TMP_FILE}"; rm -f "${SCRIPT_FILE}"; onExit;' EXIT
chmod 660 "${BACKUP_TMP_FILE}" || onFailure
chown root:identityiq "${BACKUP_TMP_FILE}" || onFailure

# Script file may have password, so ensure root only access
touch "${SCRIPT_FILE}" || onFailure
chmod 600 "${SCRIPT_FILE}" || onFailure
chown root:root "${SCRIPT_FILE}" || onFailure

if [ "$1" == "create" ]; then
    echo "#### Perform full load of all XML objects"
    scriptName="init.xml"
else
    echo "#### Perform load of only custom XML objects"
    scriptName="sp.init-custom.xml"
fi

if [ "$1" != "create" ]; then
    echo "####"
    echo "#### Provide the username and password to login to run the XML install"
    echo "#### (generally the spadmin credentials)"
    echo "####"

    read -p "#### Enter Username: " T
    echo ${T} >> "${SCRIPT_FILE}"

    read -s -p "#### Enter Password: " T
    echo ${T} >> "${SCRIPT_FILE}"
    T=""
    printf "\n"
fi

echo "export ${BACKUP_TMP_FILE} ${BACKUP_CLASSES[*]}" >> "${SCRIPT_FILE}"
echo "import ${scriptName}" >> "${SCRIPT_FILE}"

if [ -d "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/ue-plugins/install" ]; then
    for f in ${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/ue-plugins/install/*.zip; do
        echo "#### Install Plugin: `md5sum ${f}`"
        echo "plugin upgrade ${f}" >> "${SCRIPT_FILE}"
    done
fi

runuser -s /bin/bash -c "JAVA_HOME=${IIQ_FOLDER}/java ${SP_HOME}/WEB-INF/bin/iiq console" identityiq < "${SCRIPT_FILE}" || onFailure
printf "\n"

chown root:root "${BACKUP_TMP_FILE}" || onFailure
chmod 660 "${BACKUP_TMP_FILE}" || onFailure
cp -p "${BACKUP_TMP_FILE}" "${BACKUP_FILE}" || onFailure

echo "###############################"
echo "#### Loaded IIQ Configuration"
echo "#### Backup file: ${BACKUP_FILE}"

exit 0
