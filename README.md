# Labchain Hyperledger Project

Pasos para la instalacion de la red

Tener en la raiz la carpeta labchain con todas sus subcarpetas necesarias

Ejecutar los siguientes comandos de a uno

./network.sh up-ca
./network.sh enroll-and-register
./network.sh up-laboratories
./network.sh create-and-join-channel
./network.sh install-dependencies-for-chaincode
./network.sh install-chaincode
./network.sh invoke-create-order
./network.sh query-get-all-orders

Si queremos eliminar la red para volver a montarla nuevamente usar el siguiente comando:
./network.sh down
Revisar que no haya quedado ningun volumen de docker