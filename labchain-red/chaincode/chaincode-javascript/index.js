/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const assetLaboratory = require('./lib/assetLaboratory');

module.exports.AssetLaboratory = assetLaboratory;
module.exports.contracts = [assetLaboratory];
