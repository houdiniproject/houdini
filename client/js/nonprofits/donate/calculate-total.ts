import { StripeFeeStructure } from "../../../../javascripts/src/lib/payments/stripe_fee_structure";
import { Money } from "../../../../javascripts/src/lib/money";

function calculateTotal(donation:{feeCovering?:boolean, amount:number}, s:StripeFeeStructure):number {
    if (!donation.feeCovering)
        return donation.amount
    else
    {
        const originalAmount = Money.fromCents(donation.amount, 'usd')
        const reverseFee = s.reverseCalculateFee(originalAmount)
        const fullAmount = reverseFee.add(originalAmount)
        return fullAmount.amountInCents
    }
}

export {calculateTotal};