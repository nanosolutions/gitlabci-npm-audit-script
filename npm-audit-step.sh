#!/bin/bash


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
