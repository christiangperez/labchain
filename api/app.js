//import dotenv from "dotenv";
//import express from "express";
//import cors from "cors";
var express = require('express');
var cors = require('cors');
var dotenv = require('dotenv');
dotenv.config();
const app = express();

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

// dotenv.config();
app.use(cors());
app.use(express.json());

app.get("/get-all", (req, res = express.response) => {
  return res.status(200).json([
    {
      idOrder: 1,
      date: "2021-01-01",
      dniPatient: "31464386",
      namePatient: "Christian Perez",
      sexPatient: "M",
      codAna: "1050",
      matProfessional: "123",
      prescriptionDate: "2021-01-01",
      prescriptionDescription: "Classic exam",
      totalPrice: "1000",
    },
  ]);
});

app.get("/get-order/:orderId", (req, res = express.response) => {
  const { orderId } = req.params;
  return res.status(200).json({
    idOrder: orderId,
    date: "2021-01-01",
    dniPatient: "31464386",
    namePatient: "Christian Perez",
    sexPatient: "M",
    codAna: "1050",
    matProfessional: "123",
    prescriptionDate: "2021-01-01",
    prescriptionDescription: "Classic exam",
    totalPrice: "1000",
  });
});

app.post("/register-order", async (req, res = express.response) => {
  try {
		const ccp = buildCCPOrg1();
		const caClient = buildCAClient(FabricCAServices, ccp, 'ca.laboratoryA.laboratories.com');
		const wallet = await buildWallet(Wallets, walletPath);
		await enrollAdmin(caClient, wallet, mspOrg1);
		await registerAndEnrollUser(caClient, wallet, mspOrg1, org1UserId, 'laboraoryA.department1');
		const gateway = new Gateway();

		try {
			await gateway.connect(ccp, {
				wallet,
				identity: org1UserId,
				discovery: { enabled: true, asLocalhost: true }
			});
			// const network = await gateway.getNetwork(channelName);
			// const contract = network.getContract(chaincodeName);

			// console.log('\n--> Submit Transaction: RegisterOrder asset1, change the appraisedValue to 350');
			// await contract.submitTransaction('RegisterOrder', '1','2023-01-01','31464386','Christian Perez','M','123','1050','2023-01-01','Classic exam','1000');
			// console.log('*** Result: committed');

      return res.status(200).json();

		} finally {
			// Disconnect from the gateway when the application is closing
			// This will close all connections to the network
			gateway.disconnect();
		}
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
    return res.status(500).json(`******** FAILED to run the application: ${error}`);
	}
});

module.exports = app;
