import { Money } from "../../lib/money";

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
    address?:Address
    id: number
}

export interface CommonPaymentData  {
    date: string
    offsite_payment?: OffsitePayment
    donation: Donation
    kind: string
    id: string
    origin_url?: string
    charge?: Charge,
    nonprofit: { id: number }
}

export interface PaymentData extends CommonPaymentData{
    gross_amount: number
    fee_total: number
    refund_total: number
    net_amount: number
    
}

export interface PaymentDataWithMoney extends CommonPaymentData {
    gross_amount:Money
    fee_total:Money
    refund_total: Money
    net_amount: Money
}

export interface OffsitePayment {
    check_number?: string
    kind?: string
}

export interface Address {
    id?:number
    address?:string
    city?:string
    state_code?:string,
    zip_code?:string
    country?:string
}