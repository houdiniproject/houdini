// License: LGPL-3.0-or-later
import { Money } from "../money";
import { FeeStructure } from './fee_structure';
import { LegacyStripeFeeStructure } from "./legacy_stripe_fee_structure";

export type CommitchangeStripeFeeStructureProps = {flatFee:number, percentageFee:number}
/**
 * CommitChange uses a slightly different fee structure
 * @export
 * @class CommitchangeStripeFeeStructure
 */
export class CommitchangeStripeFeeStructure implements FeeStructure {
    readonly delegatedFeeStructure:FeeStructure;

    constructor(readonly props:CommitchangeStripeFeeStructureProps)
    {
        this.delegatedFeeStructure = new LegacyStripeFeeStructure({flatFee:props.flatFee, 
            percentageFee: props.percentageFee});
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