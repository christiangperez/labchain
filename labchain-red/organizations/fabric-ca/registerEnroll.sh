#!/bin/bash

function createMadrid() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/madrid.laboratories.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/madrid.laboratories.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-madrid --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-madrid.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-madrid.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-madrid.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-madrid.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-madrid --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-madrid --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-madrid --id.name madridadmin --id.secret madridadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-madrid -M "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/msp" --csr.hosts peer0.madrid.laboratories.com --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-madrid -M "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls" --enrollment.profile tls --csr.hosts peer0.madrid.laboratories.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/tlsca/tlsca.madrid.laboratories.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/ca"
  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/peers/peer0.madrid.laboratories.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/ca/ca.madrid.laboratories.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-madrid -M "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/users/User1@madrid.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/users/User1@madrid.laboratories.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://madridadmin:madridadminpw@localhost:7054 --caname ca-madrid -M "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/users/Admin@madrid.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/madrid/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/madrid.laboratories.com/users/Admin@madrid.laboratories.com/msp/config.yaml"
}

function createBogota() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/bogota.laboratories.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/bogota.laboratories.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-bogota --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bogota.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bogota.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bogota.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bogota.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-bogota --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-bogota --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-bogota --id.name bogotaadmin --id.secret bogotaadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-bogota -M "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/msp" --csr.hosts peer0.bogota.laboratories.com --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-bogota -M "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls" --enrollment.profile tls --csr.hosts peer0.bogota.laboratories.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/tlsca/tlsca.bogota.laboratories.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/ca"
  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/peers/peer0.bogota.laboratories.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/ca/ca.bogota.laboratories.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-bogota -M "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/users/User1@bogota.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/users/User1@bogota.laboratories.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://bogotaadmin:bogotaadminpw@localhost:8054 --caname ca-bogota -M "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/users/Admin@bogota.laboratories.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bogota/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bogota.laboratories.com/users/Admin@bogota.laboratories.com/msp/config.yaml"
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
