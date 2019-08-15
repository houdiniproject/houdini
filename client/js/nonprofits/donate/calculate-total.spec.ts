// License: LGPL-3.0-or-later
import {calculateTotal} from './calculate-total'
import 'jest';
import { FeeStructure } from '../../../../javascripts/src/lib/payments/fee_structure';
import {Money} from '../../../../javascripts/src/lib/money'

const x = Money.fromCents(512, 'usd')
const y = Money.fromCents( 256, 'usd')

const z = Money.fromCents(1024, 'usd')
const x_plus_z = Money.fromCents(1536, 'usd')
class TestFeeStructure implements FeeStructure
{
    calculateFee(_x: Money): Money {
        return y;
    }    
    
    reverseCalculateFee(_x: Money): Money {
        return z
    }
}

describe('calculateTotal', () => {
    it('implicitly no fee covering', () => {
        expect(calculateTotal({amount:x.amountInCents}, new TestFeeStructure)).toBe(x.amountInCents)
    })

    it('explicit no fee covering', () => {
        expect(calculateTotal({amount:x.amountInCents, feeCovering: false}, new TestFeeStructure)).toBe(x.amountInCents)
    })

    it('explicitly fee covering', () => {
        expect(calculateTotal({amount:x.amountInCents, feeCovering: true}, new TestFeeStructure)).toBe(x_plus_z.amountInCents)
    })
});