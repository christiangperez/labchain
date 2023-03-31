/*
 *  SPDX-License-Identifier: Apache-2.0
 */

'use strict';

// Bring key classes into scope, most importantly Fabric SDK network class
const fs = require('fs');
const { FileSystemWallet, Wallets } = require('fabric-network');
const path = require('path');

const fixtures = path.resolve(__dirname, '../../labchain-red/organizations/peerOrganizations/laboratoryA.laboratories.com');

// config
let config = {
  pathToUser:'/users/User1@laboratoryA.laboratories.com',
  pathToUserSignCert: '/msp/signcerts/cert.pem',
  pathToUserPrivKey: '/msp/keystore/030b86364dbddc451fe8fc9e2ce3fcb473e7f5539ab559d87ece53e66f051e28_sk',
  identityLabel: 'User1@laboratoryA.laboratories.com'
}

async function main() {

  // Main try/catch block
  

  try {

    // Identity to credentials to be stored in the wallet
    const credPath = path.join(fixtures, config.pathToUser);
    const cert = fs.readFileSync(path.join(credPath, config.pathToUserSignCert), 'utf8').toString();
    const key = fs.readFileSync(path.join(credPath, config.pathToUserPrivKey), 'utf8').toString();

     // A wallet stores a collection of identities
     const wallet = await Wallets.newFileSystemWallet('../wallet');

     const userIdentity = await wallet.get('User1');
     if (userIdentity) {
        console.log("user1 identity already exists");
        return;
     }
    const x509Identity = {
        credentials: {
            certificate: cert,
            privateKey: key,
        },
        mspId: "LaboratoryAMSP",
        type: "X.509",
    };
    await wallet.put('User1', x509Identity);
    console.log("yes");

    // Load credentials into wallet
//    const identityLabel = config.identityLabel;
    
    //const userExists = await wallet.put(identityLabel, );
    //const identity = wallet.X509WalletMixin.createIdentity('LaboratoryAMSP', cert, key);

    //await wallet.import(identityLabel, identity);

  } catch (error) {
    console.log(`Error adding to wallet. ${error}`);
    console.log(error.stack);
  }
}

main().then(() => {
    console.log('done');
}).catch((e) => {
    console.log(e);
    console.log(e.stack);
    process.exit(-1);
});