/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('./CAUtil.js');
const { buildCCPOrg1, buildWallet } = require('./AppUtil.js');

const channelName = 'laboratorieschannel';
const chaincodeName = 'basic';
const mspOrg1 = 'LaboratoryAMSP';
const walletPath = path.join(__dirname, 'wallet');
const org1UserId = 'admin';

function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}

async function main() {
	try {
		const ccp = buildCCPOrg1();
		const caClient = buildCAClient(FabricCAServices, ccp, 'ca.laboratoryA.laboratories.com');
		const wallet = await buildWallet(Wallets, walletPath);
		await enrollAdmin(caClient, wallet, mspOrg1);
		await registerAndEnrollUser(caClient, wallet, mspOrg1, org1UserId, 'laboratoryA.department1');
		const gateway = new Gateway();

		try {
			await gateway.connect(ccp, {
				wallet,
				identity: org1UserId,
				discovery: { enabled: true, asLocalhost: true }
			});
			const network = await gateway.getNetwork(channelName);
			const contract = network.getContract(chaincodeName);

			console.log('\n--> Evaluate Transaction: GetAllOrders, function returns all the current assets on the ledger');
			let result = await contract.evaluateTransaction('GetAllOrders');
			console.log(`*** Result: ${prettyJSONString(result.toString())}`);

			// console.log('\n--> Submit Transaction: RegisterOrder asset');
			// await contract.submitTransaction('RegisterOrder', '2','2023-01-01','31464386','Christian Perez','M','123','1050','2023-01-01','Classic exam','1000');
			// console.log('*** Result: committed');

			console.log('\n--> Submit Transaction: RegisterOrder, creates new asset with ID, color, owner, size, and appraisedValue arguments');
			result = await contract.submitTransaction('RegisterOrder', '3','2025-01-01','31464387','Lucas Perez','M','123','1050','2023-01-01','Classic exam','1000');
			console.log('*** Result: committed');
			if (`${result}` !== '') {
				console.log(`*** Result: ${prettyJSONString(result.toString())}`);
			}

		} finally {
			// Disconnect from the gateway when the application is closing
			// This will close all connections to the network
			gateway.disconnect();
		}
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
	}
}

main();
