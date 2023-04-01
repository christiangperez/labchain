# Labchain Hyperledger Project

Pasos para la instalacion de la red

Tener en la raiz la carpeta labchain con todas sus subcarpetas necesarias

Ejecutar los siguientes comandos de a uno posicionado siempre sobre ~/labchain/labchain-red

cd ~/labchain/labchain-red

./network.sh up-ca
./network.sh enroll-and-register
./network.sh up-laboratories
./network.sh create-and-join-channel
./network.sh install-dependencies-for-chaincode
./network.sh install-chaincode
./network.sh invoke-create-order
./network.sh query-get-all-orders

./network.sh api-up
./network.sh frontal-up

Si queremos eliminar la red para volver a montarla nuevamente usar el siguiente comando:
./network.sh down
Revisar que no haya quedado ningun volumen de docker