#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGPEER}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ${PWD}/organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGPEER}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ${PWD}/organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=Government
ORGPEER=government
P0PORT=7051
CAPORT=7054
PEERPEM=${PWD}/organizations/peerOrganizations/government.laboratories.com/tlsca/tlsca.government.laboratories.com-cert.pem
CAPEM=${PWD}/organizations/peerOrganizations/government.laboratories.com/ca/ca.government.laboratories.com-cert.pem

echo "$(json_ccp $ORG $ORGPEER $P0PORT $CAPORT $PEERPEM $CAPEM)" > ${PWD}/organizations/peerOrganizations/government.laboratories.com/connection-org1.json
echo "$(yaml_ccp $ORG $ORGPEER $P0PORT $CAPORT $PEERPEM $CAPEM)" > ${PWD}/organizations/peerOrganizations/government.laboratories.com/connection-org1.yaml

ORG=LaboratoryA
ORGPEER=laboratoryA
P0PORT=9051
CAPORT=8054
PEERPEM=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/tlsca/tlsca.laboratoryA.laboratories.com-cert.pem
CAPEM=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/ca/ca.laboratoryA.laboratories.com-cert.pem

echo "$(json_ccp $ORG $ORGPEER $P0PORT $CAPORT $PEERPEM $CAPEM)" > ${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/connection-org1.json
echo "$(yaml_ccp $ORG $ORGPEER $P0PORT $CAPORT $PEERPEM $CAPEM)" > ${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/connection-org1.yaml