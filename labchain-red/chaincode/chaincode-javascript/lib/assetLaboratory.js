/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class AssetLaboratory extends Contract {

    // RegisterOrder issues a new order to the world state with given details.
    async RegisterOrder(ctx, id, date, dni_patient, name_patient, sex_patient, cod_ana, mat_professional, prescription_date, prescription_description, total_price) {
        const asset = {
            ID: id,
            Date: date,
            DniPatient: dni_patient,
            NamePatient: name_patient,
            SexPatient: sex_patient,
            CodAna: cod_ana,
            MatProfessional: mat_professional,
            PrescriptionDate: prescription_date,
            PrescriptionDescription: prescription_description,
            TotalPrice: total_price,
        };
        ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
        return JSON.stringify(asset);
    }

    // GetOrderById returns the order stored in the world state with given id.
    async GetOrderById(ctx, id) {
        const assetJSON = await ctx.stub.getState(id); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return assetJSON.toString();
    }

    // OrderExists returns true when order with given ID exists in world state.
    async OrderExists(ctx, id) {
        const assetJSON = await ctx.stub.getState(id);
        return assetJSON && assetJSON.length > 0;
    }

    // GetAllOrders returns all orders found in the world state.
    async GetAllOrders(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: result.value.key, Record: record });
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }


}

module.exports = AssetLaboratory;
