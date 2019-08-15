// License: LGPL-3.0-or-later
import { Money } from "../money";

export interface FeeStructure {
    /**
     * Given x, calculate the fee as a portion of x. For example, using a fee structure where there's a flat percentage rate fee, if x is $10.00 (1000 cents) and the fee is 5%, this will return $.50 (50 cents)
     * @param  {Money} x 
     * @return Money 
     * @memberof FeeStructure
     */
    calculateFee(x:Money) : Money
    
    /**
     * Given x, calculate what fee must be on top of x in order to end up with x. For example, using a fee structure where there's a flat percentage rate fee, if x is $10.00 (1000 cents) and the fee is 5%, this will return ~$.52 (~52 cents). The approximate nature of this example depends on how the particular fee structure handles partial cent values.
     * @param  {Money} x 
     * @return Money 
     * @memberof FeeStructure
     */
    reverseCalculateFee(x:Money) : Money 
}
