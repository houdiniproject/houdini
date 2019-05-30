// License: LGPL-3.0-or-later

export interface FundraiserInfo {
    id: number
    name: string
}

export interface Charge {
    status: string
}

export interface RecurringDonation {
    interval?: number
    time_unit?: string
    created_at: string
}

export interface Donation {
    designation?: string
    comment?: string
    event?: { id: number }
    campaign?: { id: number }
    dedication?: string
    recurring_donation?: RecurringDonation
    id: number
}

export interface PaymentData {
    gross_amount: number
    fee_total: number
    date: string
    offsite_payment: OffsitePayment
    donation: Donation
    kind: string
    id: string
    refund_total: number
    net_amount: number
    origin_url?: string
    charge?: Charge,
    nonprofit: { id: number }
}

export interface OffsitePayment {
    check_number: string
    kind: string
}