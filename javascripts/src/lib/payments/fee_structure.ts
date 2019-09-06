// License: LGPL-3.0-or-later
import { Money } from "../money";

interface FeeStructure {
    /**
     * Given x, calculate the fee as a portion of x. For example, using a fee structure where there's a flat percentage rate fee, if x is $10.00 (1000 cents) and the fee is 5%, this will return $.50 (50 cents)
     * @param  {Money} gross 
     * @return FeeStructure.CalculationResult
     * @memberof FeeStructure
     */
    calc(gross:Money) : FeeStructure.CalculationResult
    
    /**
     * Given x, calculate what fee must be on top of x in order to end up with x. For example, using a fee structure where there's a flat percentage rate fee, if x is $10.00 (1000 cents) and the fee is 5%, this will return ~$.52 (~52 cents). The approximate nature of this example depends on how the particular fee structure handles partial cent values.
     * @param  {Money} net 
     * @return FeeStructure.CalculationResult 
     * @memberof FeeStructure
     */
    calcFromNet(net:Money) : FeeStructure.CalculationResult

    
}

namespace FeeStructure {
    
    export interface CalculationResult {
        gross: Money
        fee: Money
        net: Money
    }
}

export {FeeStructure}
