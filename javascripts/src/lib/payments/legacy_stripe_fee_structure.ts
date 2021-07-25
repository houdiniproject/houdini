// License: LGPL-3.0-or-later

import { Money } from "../money";
import { isInteger } from 'lodash';
import { FeeStructure } from './fee_structure';
import BigNumber from "bignumber.js";

type LegacyStripeFeeStructureProps = {flatFee:number, percentageFee:number}
/**
 * CommitChange uses a slightly different fee structure
 * @export
 * @class LegacyStripeFeeStructure
 */
export class LegacyStripeFeeStructure implements FeeStructure {

    constructor(readonly props:LegacyStripeFeeStructureProps)
    {
        if (!props.flatFee && !props.percentageFee) {
            throw Error(`flatFee or percentageFee must be passed`)
        }

        const def:LegacyStripeFeeStructureProps = {
            flatFee: 0,
            percentageFee: 0
        }

        props = {...def, ...props}

        if (props.percentageFee < 0 || props.percentageFee > 1)
        {
            throw Error(`percentFee must be less or equal to 1 and greater then or equal to 0`)
        }

        if (props.flatFee < 0) {
            throw Error(`flatFee must be 0 or greater`)
        }

        if (!isInteger(props.flatFee)){
            throw Error(`flatFee must be an integer as its always in the smallest currency unit`)
        }

        this.props = props;

        Object.bind(this.calc)
        Object.bind(this.calcFromNet)
        Object.freeze(this)
    }
    
    calc(gross:Money) : FeeStructure.CalculationResult {
        const fee = gross.multiply(this.props.percentageFee, BigNumber.ROUND_CEIL).add(this.props.flatFee);
        return {
            gross,
            fee,
            net: gross.subtract(fee)
        }
        
    }

    calcFromNet(net:Money): FeeStructure.CalculationResult {
        const fee =  net.add(this.props.flatFee).divide((new BigNumber(1)).minus(this.props.percentageFee)).subtract(net)
        return {
            gross: net.add(fee),
            fee,
            net
        }
    }

    static createWithPlatformFee(props:LegacyStripeFeeStructureProps & {platformFee:number}) : LegacyStripeFeeStructure {
        if (typeof props.platformFee !== 'number' || props.platformFee < 0 || props.platformFee >= 1) {
            throw new Error("platformFee must be a number and greater than or equal to 0 and less than 1")
        }
        else {
            const newProps:LegacyStripeFeeStructureProps = {
                flatFee: props.flatFee,
                percentageFee: props.percentageFee + props.platformFee
            }
            return new LegacyStripeFeeStructure(newProps)
        }
    }
}