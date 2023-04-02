# Labchain Hyperledger Project

Pasos para la instalacion de la red

Tener en la raiz la carpeta labchain con todas sus subcarpetas necesarias

Ejecutar los siguientes comandos de a uno posicionado siempre sobre ~/labchain/labchain-red

~~~
cd ~/labchain/labchain-red
~~~

### Levantar red
~~~
./network.sh up-ca
./network.sh enroll-and-register
./network.sh up-laboratories
./network.sh create-and-join-channel
./network.sh install-dependencies-for-chaincode
./network.sh install-chaincode
~~~

### Probar chaincode
~~~
./network.sh invoke-create-order
./network.sh query-get-all-orders
~~~

### Explorer
Sobre el archivo ~/labchain/labchain-red/connection-profile/laboratories-network.json, poner el nombre de archivo que se encuentra en:
~/labchain/labchain-red/organizations/peerOrganizations/laboratoryA.laboratories.com/users/User1@laboratoryA.laboratories.com/msp/keystore
sobre el campo organizations/LaboratoryAMSP/adminPrivateKey/path

~~~
cd ~/labchain/labchain-red
docker-compose up -d
~~~

### API + Frontal
~~~
./network.sh api-up
./network.sh frontal-up
~~~

### Eliminar red
Si queremos eliminar la red para volver a montarla nuevamente usar el siguiente comando:
~~~
./network.sh down
~~~
Revisar que no haya quedado ningun volumen de docker