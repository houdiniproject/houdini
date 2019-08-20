// License: LGPL-3.0-or-later
import { FeeStructure } from "../../../../javascripts/src/lib/payments/fee_structure";
import { Money } from "../../../../javascripts/src/lib/money";

function calculateTotal(donation: { feeCovering?: boolean, amount: number }, s: FeeStructure): number {
    if (!donation.feeCovering)
        return donation.amount
    else {
        const originalAmount = Money.fromCents(donation.amount, 'usd')
        const reverseFee = s.reverseCalculateFee(originalAmount)
        const fullAmount = reverseFee.add(originalAmount)
        return fullAmount.amountInCents
    }
}

function calculateFee(amount: number, s: FeeStructure): number {
    const originalAmount = Money.fromCents(amount, 'usd')
    const reverseFee = s.reverseCalculateFee(originalAmount)
    return reverseFee.amountInCents;
}

export { calculateTotal, calculateFee };