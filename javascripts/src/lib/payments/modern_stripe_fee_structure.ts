// License: LGPL-3.0-or-later
import { Money } from "../money";
import {isInteger}  from 'lodash';
import { FeeStructure } from './fee_structure';
import BigNumber from "bignumber.js";

type ModernStripeFeeStructureProps = {flatFee:number, percentFee:number, flatFeeCoveragePercent:number}
/**
 * CommitChange uses a slightly different fee structure
 * @export
 * @class ModernStripeFeeStructure
 */
export class ModernStripeFeeStructure implements FeeStructure {

    constructor(readonly props:ModernStripeFeeStructureProps)
    {
        if (!props.flatFee && !props.percentFee) {
            throw Error(`flatFee or percentFee must be passed`)
        }

        const def:ModernStripeFeeStructureProps = {
            flatFee: 0,
            percentFee: 0,
            flatFeeCoveragePercent: null,
        }

        props = {...def, ...props}

        if (props.percentFee < 0 || props.percentFee > 1)
        {
            throw Error(`percentFee must be less or equal to 1 and greater then or equal to 0`)
        }

        if (props.flatFee < 0) {
            throw Error(`flatFee must be 0 or greater`)
        }

        if (!isInteger(props.flatFee)){
            throw Error(`flatFee must be an integer as its always in the smallest currency unit`)
        }

        if (props.flatFeeCoveragePercent < 0 || props.flatFeeCoveragePercent > 1)
        {
            throw Error(`flatFeeCoveragePercent needs to be less than or equal to 1 and greater than or equal to 0`)
        }

        this.props = props;
        Object.bind(this.calc)
        Object.bind(this.calcFromNet)
        Object.freeze(this)
    }
    

    calc(gross:Money) : FeeStructure.CalculationResult {
        const fee = gross.multiply(this.props.percentFee, BigNumber.ROUND_CEIL).add(this.props.flatFee);
        return {
            gross,
            fee,
            net: gross.subtract(fee)
        }
    }
    /**
     * This returns a slightly weird result.
     * 
     * Basically, the net will not be -1 because it shouldn't actually be used.
     *
     * @param {Money} net
     * @returns {FeeStructure.CalculationResult}
     * @memberof ModernStripeFeeStructure
     */
    calcFromNet(net:Money): FeeStructure.CalculationResult {
        const fee = net.multiply(this.props.flatFeeCoveragePercent)
        return {
            gross: net.add(fee),
            fee,
            net: Money.fromCents(-1, net.currency)
        }
    }

    static createWithPlatformFee(props:ModernStripeFeeStructureProps & {platformFee:number}) : ModernStripeFeeStructure {
        if (typeof props.platformFee !== 'number' || props.platformFee < 0 || props.platformFee >= 1) {
            throw new Error("platformFee must be a number and greater than or equal to 0 and less than 1")
        }
        else {
            const newProps:ModernStripeFeeStructureProps = {
                flatFee: props.flatFee,
                percentFee: props.percentFee + props.platformFee,
                flatFeeCoveragePercent: props.flatFeeCoveragePercent
            }
            return new ModernStripeFeeStructure(newProps)
        }
    }
}