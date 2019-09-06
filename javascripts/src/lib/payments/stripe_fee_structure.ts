// License: LGPL-3.0-or-later
import {boundMethod} from 'autobind-decorator'
import { Money } from "../money";
import _ = require('lodash');
import { FeeStructure } from './fee_structure';

type StripeFeeStructureProps = {flatFee?:number, percentFee?:number}

export class StripeFeeStructure implements FeeStructure{

    constructor(readonly props:StripeFeeStructureProps)
    {
        if (!props.flatFee && !props.percentFee) {
            throw Error(`flatFee or percentFee must be passed`)
        }

        const def:StripeFeeStructureProps = {
            flatFee: 0,
            percentFee: 0
        }

        props = {...def, ...props}

        if (props.percentFee < 0 || props.percentFee > 1)
        {
            throw Error(`percentFee must be less or equal to 1 and greater then or equal to 0`)
        }

        if (props.flatFee < 0) {
            throw Error(`flatFee must be 0 or greater`)
        }

        if (!_.isInteger(props.flatFee)){
            throw Error(`flatFee must be an integer as its always in the smallest currency unit`)
        }

        this.props = props;
        Object.freeze(this.props)
    }
    
    @boundMethod
    calc(gross:Money) : FeeStructure.CalculationResult {
        const fee = Money.fromCents(Math.round(gross.amountInCents - (gross.amountInCents - this.props.flatFee - (gross.amountInCents * this.props.percentFee))), gross.currency);
        return {
            gross,
            fee,
            net: gross.subtract(fee)
        }
    }

    @boundMethod
    calcFromNet(net:Money) : FeeStructure.CalculationResult {
        const fee = Money.fromCents(Math.round(((net.amountInCents + this.props.flatFee) / (1 - this.props.percentFee) - net.amountInCents)), net.currency)

        return {
            gross: net.add(fee),
            fee,
            net
        }
    }
}