//import dotenv from "dotenv";
//import express from "express";
//import cors from "cors";
var express = require('express');
var cors = require('cors');
const { v4: uuidv4 } = require('uuid');
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

app.use(cors());
app.use(express.json());

app.get("/get-all", async (req, res = express.response) => {
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

			let result = await contract.evaluateTransaction('GetAllOrders');
      const orders = JSON.parse(result.toString());

      return res.status(200).json(orders);

		} finally {
			gateway.disconnect();
		}
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
    return res.status(500).json(`******** FAILED to run the application: ${error}`);
	}
});

app.get("/get-order/:orderId", async (req, res = express.response) => {
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

      const { orderId } = req.params;
      let result = await contract.evaluateTransaction('GetOrderById', orderId);
      const orders = JSON.parse(result.toString());

      return res.status(200).json(orders);

		} finally {
			gateway.disconnect();
		}
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
    return res.status(500).json(`******** FAILED to run the application: ${error}`);
	}
});

app.post("/register-order", async (req = express.request, res = express.response) => {
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

      const { body } = req;

      const { date,
        dniPatient,
        namePatient,
        sexPatient,
        codAna,
        matProfessional,
        prescriptionDate,
        prescriptionDescription,
        totalPrice } = body;

			result = await contract.submitTransaction('RegisterOrder', uuidv4(), date, dniPatient, namePatient, sexPatient, codAna, matProfessional, prescriptionDate, prescriptionDescription, totalPrice);

      return res.status(200).json();

		} finally {
			gateway.disconnect();
		}
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
    return res.status(500).json(`******** FAILED to run the application: ${error}`);
	}
});

module.exports = app;
