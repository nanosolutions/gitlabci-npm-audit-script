#!/bin/bash

CI_COMMIT_REF_NAME=$1
PROJECT_DOMAIN=$2
CI_COMMIT_SHORT_SHA=$3

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        COMMAND="jq-linux64"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        COMMAND="jq-osx-amd64"
fi

GITHUB="https://github.com/stedolan/jq/releases/download/jq-1.6/"

print_vulnerabilities () {
    
    echo "Report"
    npm audit
}

# print_vulnerabilities () {
#     echo "Summary "
#     ./${COMMAND} .metadata.vulnerabilities < ./audit_result.json
#     echo "Report"
#     ./${COMMAND} < ./audit_result.json
# }

if [ ! -f "$COMMAND" ]; then
    wget -q  $GITHUB$COMMAND
fi


chmod +x $COMMAND

#npm i --package-lock-only
npm -v
npm audit --json > audit_result.json

#INFO_VUL="$(./${COMMAND} .metadata.vulnerabilities.info < ./audit_result.json)"
#LOW_VUL="$(./${COMMAND} .metadata.vulnerabilities.low < ./audit_result.json)"
MODERATE_VUL="$(./${COMMAND} .metadata.vulnerabilities.moderate < ./audit_result.json)"
HIGH_VUL="$(./${COMMAND} .metadata.vulnerabilities.high < ./audit_result.json)"
CRITICAL_VUL="$(./${COMMAND} .metadata.vulnerabilities.critical < ./audit_result.json)"

SUMMARY_VUL="$(./${COMMAND} .metadata.vulnerabilities < ./audit_result.json)"


echo "Summary "
./${COMMAND} .metadata.vulnerabilities < ./audit_result.json


# if [ "$INFO_VUL" -ne "0" ]
# then
#     print_vulnerabilities
#     exit 1
# fi

# if [ "$LOW_VUL" -ne "0" ]
# then
#     print_vulnerabilities
#     exit 1
# fi

if [[ $CI_COMMIT_REF_NAME == 'master' || $CI_COMMIT_REF_NAME =~ ^[0-9]\.[0-9]\.[0-9]$ ]]
then
    curl -L -X POST https://chief.nano.rocks/api/report -F "report=@audit_result.json" -F "metadata={\"type\":\"npm\",\"version\":\"6\",\"project\":\"$PROJECT_DOMAIN\",\"ref\":\"$CI_COMMIT_REF_NAME\", \"sha\":\"$CI_COMMIT_SHORT_SHA\"}"
fi

if [ "$MODERATE_VUL" -ne "0" ]
then
    print_vulnerabilities
    exit 1
fi

if [ "$HIGH_VUL" -ne "0" ]
then
    print_vulnerabilities
    exit 1
fi

if [ "$CRITICAL_VUL" -ne "0" ]
then
    print_vulnerabilities
    exit 1
fi
