'use strict';
const sinon = require('sinon');
const chai = require('chai');
const sinonChai = require('sinon-chai');
const expect = chai.expect;

const { Context } = require('fabric-contract-api');
const { ChaincodeStub } = require('fabric-shim');

const AssetLaboratory = require('../lib/assetLaboratory.js');

let assert = sinon.assert;
chai.use(sinonChai);

describe('Asset Laboratory Basic Tests', () => {
    let transactionContext, chaincodeStub, asset;
    beforeEach(() => {
        transactionContext = new Context();

        chaincodeStub = sinon.createStubInstance(ChaincodeStub);
        transactionContext.setChaincodeStub(chaincodeStub);

        chaincodeStub.putState.callsFake((key, value) => {
            if (!chaincodeStub.states) {
                chaincodeStub.states = {};
            }
            chaincodeStub.states[key] = value;
        });

        chaincodeStub.getState.callsFake(async (key) => {
            let ret;
            if (chaincodeStub.states) {
                ret = chaincodeStub.states[key];
            }
            return Promise.resolve(ret);
        });

        chaincodeStub.deleteState.callsFake(async (key) => {
            if (chaincodeStub.states) {
                delete chaincodeStub.states[key];
            }
            return Promise.resolve(key);
        });

        chaincodeStub.getStateByRange.callsFake(async () => {
            function* internalGetStateByRange() {
                if (chaincodeStub.states) {
                    // Shallow copy
                    const copied = Object.assign({}, chaincodeStub.states);

                    for (let key in copied) {
                        yield {value: copied[key]};
                    }
                }
            }

            return Promise.resolve(internalGetStateByRange());
        });

        asset = {
            ID: '1', 
            Date: '2023-01-01', 
            DniPatient: '31464386', 
            NamePatient: 'Christian Perez', 
            SexPatient: 'M', 
            CodAna: '1050', 
            MatProfessional: '123', 
            PrescriptionDate: '2023-01-01', 
            PrescriptionDescription: 'Classic exam', 
            TotalPrice: '1000'
        };
    });

    describe('Test CreateOrder', () => {
        it('should return error on CreateOrder', async () => {
            chaincodeStub.putState.rejects('failed inserting key');

            let assetLaboratory = new AssetLaboratory();
            try {
                await assetLaboratory.CreateOrder(transactionContext, asset.Id, asset.Date, asset.DniPatient, asset.NamePatient, asset.SexPatient, asset.CodAna, asset.MatProfessional, asset.PrescriptionDate, asset.PrescriptionDescription, asset.TotalPrice);
                assert.fail('CreateOrder should have failed');
            } catch(err) {
                expect(err.name).to.equal('failed inserting key');
            }
        });

        it('should return success on CreateOrder', async () => {
            let assetLaboratory = new AssetLaboratory();

            await assetLaboratory.CreateOrder(transactionContext, asset.Id, asset.Date, asset.DniPatient, asset.NamePatient, asset.SexPatient, asset.CodAna, asset.MatProfessional, asset.PrescriptionDate, asset.PrescriptionDescription, asset.TotalPrice);

            let ret = JSON.parse((await chaincodeStub.getState(asset.ID)).toString());
            expect(ret).to.eql(asset);
        });
    });

    describe('Test GetAllOrders', () => {
        it('should return success on GetAllOrders', async () => {
            let assetLaboratory = new AssetLaboratory();

            await assetLaboratory.CreateOrder(transactionContext, '1','2023-01-01','31464386','Christian Perez','M','123','1050','2023-01-01','Classic exam','1000');
            await assetLaboratory.CreateOrder(transactionContext, '2','2023-01-02','31464387','Gabriel Perez','M','123','1050','2023-01-01','Classic exam','1000');
            await assetLaboratory.CreateOrder(transactionContext, '3','2023-01-03','31464388','Lucas Perez','M','123','1050','2023-01-01','Classic exam','1000');
            await assetLaboratory.CreateOrder(transactionContext, '4','2023-01-04','31464389','Alejandro Perez','M','123','1050','2023-01-01','Classic exam','1000');

            let ret = await assetLaboratory.GetAllOrders(transactionContext);
            ret = JSON.parse(ret);
            expect(ret.length).to.equal(4);

            let expected = [
                {Record: {ID: '1', Date: '2023-01-01', DniPatient: '31464386', NamePatient: 'Christian Perez', SexPatient: 'M', CodAna: '1050', MatProfessional: '123', PrescriptionDate: '2023-01-01', PrescriptionDescription: 'Classic exam', TotalPrice: '1000'}},
                {Record: {ID: '2', Date: '2023-01-02', DniPatient: '31464387', NamePatient: 'Gabiel Perez', SexPatient: 'M', CodAna: '1050', MatProfessional: '123', PrescriptionDate: '2023-01-01', PrescriptionDescription: 'Classic exam', TotalPrice: '1000'}},
                {Record: {ID: '3', Date: '2023-01-03', DniPatient: '31464388', NamePatient: 'Lucas Perez', SexPatient: 'M', CodAna: '1050', MatProfessional: '123', PrescriptionDate: '2023-01-01', PrescriptionDescription: 'Classic exam', TotalPrice: '1000'}},
                {Record: {ID: '4', Date: '2023-01-04', DniPatient: '31464389', NamePatient: 'Alejandro Perez', SexPatient: 'M', CodAna: '1050', MatProfessional: '123', PrescriptionDate: '2023-01-01', PrescriptionDescription: 'Classic exam', TotalPrice: '1000'}}
            ];

            expect(ret).to.eql(expected);
        });

        it('should return success on GetAllOrders for non JSON value', async () => {
            let assetLaboratory = new AssetLaboratory();

            chaincodeStub.putState.onFirstCall().callsFake((key, value) => {
                if (!chaincodeStub.states) {
                    chaincodeStub.states = {};
                }
                chaincodeStub.states[key] = 'non-json-value';
            });

            await assetLaboratory.CreateAsset(transactionContext, '1','2023-01-01','31464386','Christian Perez','M','123','1050','2023-01-01','Classic exam','1000');
            await assetLaboratory.CreateAsset(transactionContext, '2','2023-01-02','31464387','Gabriel Perez','M','123','1050','2023-01-01','Classic exam','1000');
            await assetLaboratory.CreateAsset(transactionContext, '3','2023-01-03','31464388','Lucas Perez','M','123','1050','2023-01-01','Classic exam','1000');
            await assetLaboratory.CreateAsset(transactionContext, '4','2023-01-04','31464389','Alejandro Perez','M','123','1050','2023-01-01','Classic exam','1000');

            let ret = await assetLaboratory.GetAllAssets(transactionContext);
            ret = JSON.parse(ret);
            expect(ret.length).to.equal(4);

            let expected = [
                {Record: 'non-json-value'},
                {Record: {ID: '2', Date: '2023-01-02', DniPatient: '31464387', NamePatient: 'Gabiel Perez', SexPatient: 'M', CodAna: '1050', MatProfessional: '123', PrescriptionDate: '2023-01-01', PrescriptionDescription: 'Classic exam', TotalPrice: '1000'}},
                {Record: {ID: '3', Date: '2023-01-03', DniPatient: '31464388', NamePatient: 'Lucas Perez', SexPatient: 'M', CodAna: '1050', MatProfessional: '123', PrescriptionDate: '2023-01-01', PrescriptionDescription: 'Classic exam', TotalPrice: '1000'}},
                {Record: {ID: '4', Date: '2023-01-04', DniPatient: '31464389', NamePatient: 'Alejandro Perez', SexPatient: 'M', CodAna: '1050', MatProfessional: '123', PrescriptionDate: '2023-01-01', PrescriptionDescription: 'Classic exam', TotalPrice: '1000'}}
            ];

            expect(ret).to.eql(expected);
        });
    });
});
