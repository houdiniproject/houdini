# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
shared_context "payments for a payout" do
  before { @expect_marked = {charges: [], disputes: [], refunds: [], payouts_records: []} }

  let(:all_payments) do
    payment_with_charge_to_output
    partial_refunded_payment
    refunded_payment
    disputed_payment
    late_payment
    paid_out_payment
    paid_out_refund
    paid_out_dispute
    other_np_payment
  end

  # net amount: 1600
  let(:payment_with_charge_to_output) do
    p = create_marked_payment
    create_marked_charge(payment: p, amount: 2000, fee: -400, status: "available")
    return p
  end

  # net amount: 1100
  let(:partial_refunded_payment) do
    p = create_marked_payment
    c = create_marked_charge(payment: p, amount: 2000, fee: -400, status: "available")

    refund_payment = create_marked_payment(gross_amount: -500, fee_total: 0, net_amount: -500)
    create_marked_refund(charge: c, payment: refund_payment, amount: 500)
    return p
  end

  # net amount: 0
  let(:refunded_payment) do
    p = create_marked_payment
    c = create_marked_charge(payment: p, amount: 2000, status: "available")
    refund_payment = create_marked_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
    create_marked_refund(charge: c, payment: refund_payment, amount: 2000, disbursed: false)
    return p
  end

  # net amount: 0
  let(:disputed_payment) do
    p = create_marked_payment
    c = create_marked_charge(payment: p, amount: 2000, status: "available")

    p2 = create_marked_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
    create_marked_dispute(charge: c, payment: p2, gross_amount: 2000, status: "lost")
    return p
  end

  # net amount: 1600
  let(:late_payment) do
    is_this_marked = Time.now.beginning_of_day <= date_for_marking.beginning_of_day
    p = create_payment(date: Time.now, marked: is_this_marked)
    create_charge(payment: p, amount: 2000, status: "available", marked: is_this_marked)

    return p
  end

  # net amount: 0
  let(:paid_out_payment) do
    p = create_payment
    create_charge(payment: p, amount: 2000, status: "disbursed")
    return p
  end

  # net amount: 0
  let(:paid_out_refund) do
    p = create_payment
    create_charge(payment: p, amount: 2000, status: "disbursed")
    refunded_payment = create_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
    create_refund(payment: refunded_payment, disbursed: true)
    return p
  end

  # net amount: 0
  let(:paid_out_dispute) do
    p = create_payment
    c = create_charge(payment: p, amount: 2000, status: "disbursed")
    dispute_payment = create_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
    create_dispute(charge: c, payment: dispute_payment, gross_amount: 2000, status: "lost_and_paid")
    return p
  end

  let(:other_np_payment) do
    p = create_payment(nonprofit: force_create(:fv_poverty))
    create_charge(payment: p, amount: 2000, fee: -400, status: "available")
    return p
  end

  def create_marked_payment(args = {})
    create_payment(args.merge(marked: true))
  end

  def create_payment(args = {})
    expect_payment = args[:marked]
    p = force_create(:payment, {nonprofit: np, date: Time.now - 1.day, gross_amount: 2000, fee_total: -400, net_amount: 1600}.merge(args.except(:marked)))
    @expect_marked[:payouts_records].push(p) if expect_payment
    p
  end

  def create_marked_refund(args = {})
    create_refund(args.merge(marked: true))
  end

  def create_refund(args = {})
    expect_refund = args[:marked]
    r = force_create(:refund, args.except(:marked))
    @expect_marked[:refunds].push(r) if expect_refund
    r
  end

  def create_marked_charge(args = {})
    create_charge(args.merge(marked: true))
  end

  def create_charge(args = {})
    expect_charge = args[:marked]
    c = force_create(:charge, args.except(:marked))
    @expect_marked[:charges].push(c) if expect_charge
    c
  end

  def create_marked_dispute(args = {})
    create_dispute(args.merge(marked: true))
  end

  def create_dispute(args = {})
    expect_dispute = args[:marked]
    d = force_create(:dispute, args.except(:marked))
    @expect_marked[:disputes].push(d) if expect_dispute
    d
  end

  # provide let(date_for_marking)
end
