# labchain hyperledger project

Pasos para la instalacion de la red

Tener en la raiz la carpeta labchain con todas sus subcarpetas necesarias

Ejecutar los siguientes comandos de a uno

cd ~/labchain/labchain-red
./network.sh down
./network.sh up-ca
./network.sh enroll-and-register
./network.sh up-laboratories
./network.sh create-and-join-channel
./network.sh install-dependencies-for-chaincode
./network.sh install-chaincode
./network.sh chaincode-invoke
./network.sh chaincode-query