// License: LGPL-3.0-or-later
import { FeeStructure } from "../../../../javascripts/src/lib/payments/fee_structure";
import { Money } from "../../../../javascripts/src/lib/money";

function calculateTotal(donation: { feeCovering?: boolean, amount: number }, s: FeeStructure): number {
    if (!donation.feeCovering)
        return donation.amount
    else {
        const originalAmount = Money.fromCents(donation.amount, 'usd')
        return s.calcFromNet(originalAmount).gross.amountInCents
    }
}

export { calculateTotal };