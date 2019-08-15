// License: LGPL-3.0-or-later
import {boundMethod} from 'autobind-decorator'
import { Money } from "../money";
import _ = require('lodash');
import { FeeStructure } from './fee_structure';
import { platform } from 'os';

type CommitchangeStripeFeeStructureProps = {flatFee:number, percentFee:number}
/**
 * CommitChange uses a slightly different fee structure
 * @export
 * @class CommitchangeStripeFeeStructure
 */
export class CommitchangeStripeFeeStructure implements FeeStructure {

    protected constructor(readonly props:CommitchangeStripeFeeStructureProps)
    {
        if (!props.flatFee && !props.percentFee) {
            throw Error(`flatFee or percentFee must be passed`)
        }

        const def:CommitchangeStripeFeeStructureProps = {
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
    }
    
    @boundMethod
    calculateFee(x:Money) : Money {
        const cents= x.amountInCents;
        return Money.fromCents(Math.ceil(cents * this.props.percentFee) + this.props.flatFee, x.currency);
    }

    @boundMethod
    reverseCalculateFee(x:Money):Money {
        return Money.fromCents(Math.ceil(((x.amountInCents + this.props.flatFee) / (1 - this.props.percentFee) - x.amountInCents)), x.currency)
    }

    static createWithPlatformFee(props:CommitchangeStripeFeeStructureProps & {platformFee:number}) : CommitchangeStripeFeeStructure {
        if (typeof props.platformFee !== 'number' || props.platformFee < 0 || props.platformFee >= 1) {
            throw new Error("platformFee must be a number and greater than or equal to 0 and less than 1")
        }
        else {
            const newProps:CommitchangeStripeFeeStructureProps = {
                flatFee: props.flatFee,
                percentFee: props.percentFee + props.platformFee
            }
            return new CommitchangeStripeFeeStructure(newProps)
        }
    }
}