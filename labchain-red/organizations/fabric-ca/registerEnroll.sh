#!/bin/bash

function createGovernment() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/government.laboratories.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/government.laboratories.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-government --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-government.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-government.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-government.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-government.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/government.laboratories.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-government --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-government --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-government --id.name governmentadmin --id.secret governmentadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-government -M "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/msp" --csr.hosts peer0.government.laboratories.com --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-government -M "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls" --enrollment.profile tls --csr.hosts peer0.government.laboratories.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/government.laboratories.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/government.laboratories.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/government.laboratories.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/government.laboratories.com/tlsca/tlsca.government.laboratories.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/government.laboratories.com/ca"
  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/government.laboratories.com/ca/ca.government.laboratories.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-government -M "${PWD}/organizations/peerOrganizations/government.laboratories.com/users/User1@government.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/government.laboratories.com/users/User1@government.laboratories.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://governmentadmin:governmentadminpw@localhost:7054 --caname ca-government -M "${PWD}/organizations/peerOrganizations/government.laboratories.com/users/Admin@government.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/government/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/government.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/government.laboratories.com/users/Admin@government.laboratories.com/msp/config.yaml"
}

function createLaboratoryA() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/laboratoryA.laboratories.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-laboratoryA --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-laboratoryA.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-laboratoryA.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-laboratoryA.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-laboratoryA.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-laboratoryA --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-laboratoryA --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-laboratoryA --id.name laboratoryAadmin --id.secret laboratoryAadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-laboratoryA -M "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/msp" --csr.hosts peer0.laboratoryA.laboratories.com --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-laboratoryA -M "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls" --enrollment.profile tls --csr.hosts peer0.laboratoryA.laboratories.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/tlsca/tlsca.laboratoryA.laboratories.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/ca"
  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/ca/ca.laboratoryA.laboratories.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-laboratoryA -M "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/User1@laboratoryA.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/User1@laboratoryA.laboratories.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://laboratoryAadmin:laboratoryAadminpw@localhost:8054 --caname ca-laboratoryA -M "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/Admin@laboratoryA.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/laboratoryA/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/Admin@laboratoryA.laboratories.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/laboratories.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/laboratories.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/laboratories.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp" --csr.hosts orderer.laboratories.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/laboratories.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls" --enrollment.profile tls --csr.hosts orderer.laboratories.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/laboratories.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/laboratories.com/users/Admin@laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/laboratories.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/laboratories.com/users/Admin@laboratories.com/msp/config.yaml"
}
