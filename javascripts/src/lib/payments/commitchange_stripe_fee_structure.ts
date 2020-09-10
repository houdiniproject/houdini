// License: LGPL-3.0-or-later
import { Money } from "../money";
import _ = require('lodash');
import { FeeStructure } from './fee_structure';
import { LegacyStripeFeeStructure } from "./legacy_stripe_fee_structure";
import { ModernStripeFeeStructure } from "./modern_stripe_fee_structure";

type CommitchangeStripeFeeStructureProps = {flatFee:number, percentFee:number, feeSwitchoverTime:Date, flatFeeCoveragePercent:number}
/**
 * CommitChange uses a slightly different fee structure
 * @export
 * @class CommitchangeStripeFeeStructure
 */
export class CommitchangeStripeFeeStructure implements FeeStructure {
    readonly delegatedFeeStructure:FeeStructure;

    constructor(readonly props:CommitchangeStripeFeeStructureProps)
    {
        if (new Date() < props.feeSwitchoverTime) {
            this.delegatedFeeStructure = new LegacyStripeFeeStructure({flatFee: props.flatFee, percentFee: props.percentFee})
        }
        else {
            this.delegatedFeeStructure = new ModernStripeFeeStructure({flatFee:props.flatFee, 
                percentFee: props.percentFee, 
                flatFeeCoveragePercent: props.flatFeeCoveragePercent});
        }
        Object.bind(this.calc)
        Object.bind(this.calcFromNet)
        Object.freeze(this)
    }
    
    calc(gross:Money) : FeeStructure.CalculationResult {
       return this.delegatedFeeStructure.calc(gross);
    }

    calcFromNet(net:Money): FeeStructure.CalculationResult {
        return this.delegatedFeeStructure.calcFromNet(net);
    }
}