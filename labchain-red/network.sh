function networkDown() {
  cd ~/labchain/labchain-red
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
  docker volume prune
  docker network prune
  sudo rm -rf organizations/peerOrganizations
  sudo rm -rf organizations/ordererOrganizations
  sudo rm -rf organizations/fabric-ca/government/
  sudo rm -rf organizations/fabric-ca/laboratoryA/
  sudo rm -rf organizations/fabric-ca/ordererOrg/
  sudo rm basic.tar.gz
  rm -rf channel-artifacts/
}

function startCA() {
  mkdir channel-artifacts
  export PATH=${PWD}/../bin:${PWD}:$PATH
  export FABRIC_CFG_PATH=${PWD}/../config
  docker-compose -f docker/docker-compose-ca.yaml up -d
}

function createGovernment() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/government.laboratories.com/

  export PATH=${PWD}/../bin:${PWD}:$PATH
  export FABRIC_CFG_PATH=${PWD}/../config
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


function enrollAndRegister() {
  createGovernment
  sleep 3
  createLaboratoryA
  sleep 3
  createOrderer
}

function generateCpp() {
  ./cpp-generate.sh
}

function networkUp() {
  docker-compose -f docker/docker-compose-laboratories.yaml up -d
}

function createAndJoinChannel() {
  export PATH=${PWD}/../bin:${PWD}:$PATH
  export FABRIC_CFG_PATH=${PWD}/configtx
  configtxgen -profile LaboratoriesGenesis -outputBlock ./channel-artifacts/laboratorieschannel.block -channelID laboratorieschannel
  export FABRIC_CFG_PATH=${PWD}/../config
  export ORDERER_CA=${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem
  export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/server.crt
  export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/tls/server.key
  osnadmin channel join --channelID laboratorieschannel --config-block ./channel-artifacts/laboratorieschannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
  osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
  export CORE_PEER_TLS_ENABLED=true
  export PEER0_GOVERNMENT_CA=${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="GovernmentMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_GOVERNMENT_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/government.laboratories.com/users/Admin@government.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
  peer channel join -b ./channel-artifacts/laboratorieschannel.block
  export PEER0_LABORATORYA_CA=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="LaboratoryAMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LABORATORYA_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/Admin@laboratoryA.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
  peer channel join -b ./channel-artifacts/laboratorieschannel.block
}

function installDependenciesForChaincode() {
  cd ${PWD}/chaincode/chaincode-javascript
  npm install
}

function installChaincode() {
  cd ~/labchain/labchain-red
  export PATH=${PWD}/../bin:${PWD}:$PATH
  export FABRIC_CFG_PATH=${PWD}/../config
  peer lifecycle chaincode package basic.tar.gz --path chaincode/chaincode-javascript/ --lang node --label basic_1.0
  export PEER0_GOVERNMENT_CA=${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="GovernmentMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_GOVERNMENT_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/government.laboratories.com/users/Admin@government.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
  peer lifecycle chaincode install basic.tar.gz
  export PEER0_LABORATORYA_CA=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="LaboratoryAMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LABORATORYA_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/Admin@laboratoryA.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
  peer lifecycle chaincode install basic.tar.gz
  peer lifecycle chaincode queryinstalled
  export CC_PACKAGE_ID=basic_1.0:ff3e05e59e73050096b31660d895bbb7f42eb44b9ed9309449bb5c5353e2a9d8
  peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --channelID laboratorieschannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem --signature-policy "OR('GovernmentMSP.member','LaboratoryAMSP.member')"
  export PEER0_GOVERNMENT_CA=${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="GovernmentMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_GOVERNMENT_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/government.laboratories.com/users/Admin@government.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
  peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --channelID laboratorieschannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem --signature-policy "OR('GovernmentMSP.member','LaboratoryAMSP.member')"
  peer lifecycle chaincode checkcommitreadiness --channelID laboratorieschannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem --output json
  peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --channelID laboratorieschannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt --signature-policy "OR('GovernmentMSP.member','LaboratoryAMSP.member')"
  peer lifecycle chaincode querycommitted --channelID laboratorieschannel --name basic --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem
}

function apiUp() {
  cd ~/labchain/labchain-red/organizations/peerOrganizations/laboratoryA.laboratories.com
  cp connection-org1.json ../../../../api/connection-org1.json

  cd ~/labchain/api
  rm -rf wallet/
  node index
}

function frontalUp() {
  cd ~/labchain/frontal
  npm start
}

function invokeCreateOrder() {
  export PEER0_LABORATORYA_CA=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="LaboratoryAMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LABORATORYA_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/Admin@laboratoryA.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem -C laboratorieschannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt -c '{"function":"RegisterOrder","Args":["c7172c87-a890-412c-8aea-c2f8325eb5af","2023-01-01","31464386","Christian Perez","M","123","1050","2023-01-01","Classic exam","1000"]}'
}

function invokeGetOrderById() {
  export PEER0_LABORATORYA_CA=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="LaboratoryAMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LABORATORYA_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/Admin@laboratoryA.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
  peer chaincode query -C laboratorieschannel -n basic -c '{"function":"GetOrderById","Args":["c7172c87-a890-412c-8aea-c2f8325eb5af"]}'
}

function queryGetAllOrders() {
  export PEER0_LABORATORYA_CA=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="LaboratoryAMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LABORATORYA_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/users/Admin@laboratoryA.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
  peer chaincode query -C laboratorieschannel -n basic -c '{"Args":["GetAllOrders"]}'
}
function startAll() {
  startCA
  sleep 10
  enrollAndRegister
  sleep 10
  generateCpp
  sleep 5
  networkUp
  sleep 15
  createAndJoinChannel
}

function println() {
  echo -e "$1"
}

function infoln() {
  println "${C_BLUE}${1}${C_RESET}"
}

function printHelp() {
  println "Usage: "
    println "  network.sh \033[0;32mflag\033[0m"
    println
    println "    Flags:"
    println "    down                               - Shut down network and remove unnecessary files"
    println "    up-ca                              - Start dockers for the CAs"
    println "    enroll-and-register                - Enroll and register with the CA"
    println "    generate-cpp                       - Generate CPP files"
    println "    up-laboratories                    - Start network"
    println "    create-and-join-channel            - Create and join in channel"
    println "    install-dependencies-for-chaincode - Install the dependencies for Javascript chaincode (node_modules)"
    println "    install-chaincode                  - Install chaincode"
    println "    api-up                             - Start APIcode"
    println "    frontal-up                         - Start Frontal"
    println "    invoke-create-order                - Invoke CreateOrder method of the chaincode"
    println "    invoke-get-order-by-id             - Invoke GetOrderById method of the chaincode"
    println "    query-get-all-orders               - Query GetAllOrders method of the chaincode"
}

# Parse Flags
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

# Calling flags functions
if [ "${MODE}" == "down" ]; then
  infoln "Stopping network"
  networkDown
elif [ "${MODE}" == "up-ca" ]; then
  infoln "Starting CAs"
  startCA
elif [ "${MODE}" == "enroll-and-register" ]; then
  infoln "Enrolling and registering"
  enrollAndRegister
elif [ "${MODE}" == "generate-cpp" ]; then
  infoln "CPPs Generated"
  generateCpp
elif [ "${MODE}" == "up-laboratories" ]; then
  infoln "Starting laboratories network"
  networkUp
elif [ "${MODE}" == "create-and-join-channel" ]; then
  infoln "Creating channel and joinning"
  createAndJoinChannel
elif [ "${MODE}" == "install-dependencies-for-chaincode" ]; then
  infoln "Installing dependencies for Chaincode (npm install - node_modules)"
  installDependenciesForChaincode
elif [ "${MODE}" == "install-chaincode" ]; then
  infoln "Installing Chaincode"
  installChaincode
elif [ "${MODE}" == "api-up" ]; then
  infoln "Starting API"
  apiUp
elif [ "${MODE}" == "frontal-up" ]; then
  infoln "Starting Frontal"
  frontalUp
elif [ "${MODE}" == "invoke-create-order" ]; then
  infoln "Invoking Chaincode method CreateOrder"
  invokeCreateOrder
elif [ "${MODE}" == "invoke-get-order-by-id" ]; then
  infoln "Invoking Chaincode method GetOrderById"
  invokeGetOrderById
elif [ "${MODE}" == "query-get-all-orders" ]; then
  infoln "Query Chaincode method GetAllOrders"
  queryGetAllOrders
elif [ "${MODE}" == "start-all" ]; then
  infoln "Starting all network commands"
  startAll
else
  infoln "Invalid flag"
  printHelp
  exit 1
fi
