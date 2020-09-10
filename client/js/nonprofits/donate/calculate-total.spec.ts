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
    calc(x: Money) {
        return {
            gross:x,
            fee: x.subtract(y),
            net: y
        }
        
    }    
    
    calcFromNet(x: Money) {
        return {
            gross: z,
            fee: z.subtract(x),
            net: x

        }
    }
}

describe('calculateTotal', () => {
    it('implicitly no fee covering', () => {
        expect(calculateTotal({amount:x.amountInCents.toNumber()}, new TestFeeStructure)).toBe(x.amountInCents.toNumber())
    })

    it('explicit no fee covering', () => {
        expect(calculateTotal({amount:x.amountInCents.toNumber(), feeCovering: false}, new TestFeeStructure)).toBe(x.amountInCents.toNumber())
    })

    it('explicitly fee covering', () => {
        expect(calculateTotal({amount:x.amountInCents.toNumber(), feeCovering: true}, new TestFeeStructure)).toBe(z.amountInCents.toNumber())
    })
});