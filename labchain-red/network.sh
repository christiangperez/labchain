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

function enrollAndRegister() {
  . ./organizations/fabric-ca/registerEnroll.sh && createGovernment
  . ./organizations/fabric-ca/registerEnroll.sh && createLaboratoryA
  . ./organizations/fabric-ca/registerEnroll.sh && createOrderer
}

function networkUp() {
  docker-compose -f docker/docker-compose-laboratories.yaml up -d
}

function createAndJoinChannel() {
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
  export CC_PACKAGE_ID=basic_1.0:42ec06cd56ec32a153af3d335b1a18e7ec3dae039b96698f933f464e7abf2a3e
  peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --channelID laboratorieschannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem
  export PEER0_GOVERNMENT_CA=${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="GovernmentMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_GOVERNMENT_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/government.laboratories.com/users/Admin@government.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
  peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --channelID laboratorieschannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem
  peer lifecycle chaincode checkcommitreadiness --channelID laboratorieschannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem --output json
  peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --channelID laboratorieschannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt
  peer lifecycle chaincode querycommitted --channelID laboratorieschannel --name basic --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem
}

function chaincodeInvoke() {
  export PEER0_GOVERNMENT_CA=${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="GovernmentMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_GOVERNMENT_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/government.laboratories.com/users/Admin@government.laboratories.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.laboratories.com --tls --cafile ${PWD}/organizations/ordererOrganizations/laboratories.com/orderers/orderer.laboratories.com/msp/tlscacerts/tlsca.laboratories.com-cert.pem -C laboratorieschannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/government.laboratories.com/peers/peer0.government.laboratories.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/laboratoryA.laboratories.com/peers/peer0.laboratoryA.laboratories.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
}

function chaincodeQuery() {
  peer chaincode query -C laboratorieschannel -n basic -c '{"Args":["GetAllAssets"]}'
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
    println "    up-laboratories                    - Start network"
    println "    create-and-join-channel            - Create and join in channel"
    println "    install-dependencies-for-chaincode - Install the dependencies for Javascript chaincode (node_modules)"
    println "    install-chaincode                  - Install chaincode"
    println "    chaincode-invoke                   - Invoke init method of the chaincode"
    println "    chaincode-query                    - Invoke GetAllAssets method of the chaincode"
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
elif [ "${MODE}" == "chaincode-invoke" ]; then
  infoln "Invoking Chaincode method InitLedger"
  chaincodeInvoke
elif [ "${MODE}" == "chaincode-query" ]; then
  infoln "Invoking Chaincode method GetAllAssets"
  chaincodeQuery
else
  infoln "Invalid flag"
  printHelp
  exit 1
fi
