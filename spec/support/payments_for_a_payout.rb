# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
shared_context 'payments for a payout' do
  before(:each) {@expect_marked = {charges: Array.new, disputes: Array.new, refunds: Array.new, payouts_records: Array.new}}
  let(:all_payments) {
    payment_with_charge_to_output
    partial_refunded_payment
    refunded_payment
    disputed_payment
    late_payment
    paid_out_payment
    paid_out_refund
    paid_out_dispute
    other_np_payment
  }

  #net amount: 1600
  let(:payment_with_charge_to_output) {
    p = create_marked_payment
    create_marked_charge(payment: p, amount: 2000, fee: -400, status: 'available')
    return p
  }

  #net amount: 1100
  let(:partial_refunded_payment) {
    p = create_marked_payment
    c = create_marked_charge(payment: p, amount: 2000, fee: -400, status: 'available')

    refund_payment = create_marked_payment(gross_amount: -500, fee_total: 0, net_amount: -500)
    create_marked_refund(charge: c, payment: refund_payment, amount: 500)
    return p
  }

  #net amount: 0
  let(:refunded_payment) {
    p = create_marked_payment
    c = create_marked_charge(payment: p, amount: 2000, status: 'available')
    refund_payment = create_marked_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
    create_marked_refund(charge: c, payment: refund_payment, amount: 2000, disbursed: false)
    return p
  }

  #net amount: 0
  let(:disputed_payment) {
    p = create_marked_payment
    c = create_marked_charge(payment: p, amount: 2000, status: 'available')

    p2 = create_marked_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
    create_marked_dispute(charge: c, payment: p2, gross_amount: 2000, status: 'lost')
    return p
  }

  #net amount: 1600
  let(:late_payment) {
    is_this_marked = Time.now.beginning_of_day <= date_for_marking.beginning_of_day
    p = create_payment(date: Time.now, marked: is_this_marked)
    c = create_charge(payment: p, amount: 2000, status: 'available', marked: is_this_marked)

    return p
  }

  #net amount: 0
  let(:paid_out_payment) {
    p = create_payment
    c = create_charge(payment: p, amount: 2000, status: 'disbursed')
    return p
  }

  #net amount: 0
  let(:paid_out_refund) {
    p = create_payment
    c = create_charge(payment: p, amount: 2000, status: 'disbursed')
    refunded_payment = create_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
    refund = create_refund(payment: refunded_payment, disbursed: true)
    return p
  }


  #net amount: 0
  let(:paid_out_dispute) {
    p = create_payment
    c = create_charge(payment: p, amount: 2000, status: 'disbursed')
    dispute_payment = 
    dispute = create_dispute(charge: c, gross_amount: 2000, status: 'lost')
    dispute.dispute_transactions.create(payment: 
    return p
  }

  let(:other_np_payment) {
    p = create_payment(nonprofit: force_create(:nonprofit))
    create_charge(payment: p, amount: 2000, fee: -400, status: 'available')
    return p
  }

  def create_marked_payment(args = {})
    return create_payment(args.merge({marked: true}))
  end

  def create_payment(args = {})
    expect_payment = args[:marked]
    p = force_create(:payment, {nonprofit: np, date: Time.now - 1.day, gross_amount: 2000, fee_total: -400, net_amount: 1600}.merge(args.except(:marked)))
    if (expect_payment)
      @expect_marked[:payouts_records].push(p)
    end
    p
  end

  def create_marked_refund(args = {})
    create_refund(args.merge({marked: true}))
  end


  def create_refund(args = {})
    expect_refund = args[:marked]
    r = force_create(:refund, args.except(:marked))
    if (expect_refund)
      @expect_marked[:refunds].push(r)
    end
    r
  end

  def create_marked_charge(args = {})
    create_charge(args.merge({marked: true}))
  end

  def create_charge(args = {})
    expect_charge = args[:marked]
    c = force_create(:charge, args.except(:marked))
    if (expect_charge)
      @expect_marked[:charges].push(c)
    end
    c
  end

  def create_marked_dispute(args = {})
    create_dispute(args.merge({marked: true}))
  end

  def create_dispute(args = {})
    expect_dispute = args[:marked]
    d = force_create(:dispute, args.except(:marked))
    if (expect_dispute)
      @expect_marked[:disputes].push(d)
    end
    d
  end


  #provide let(date_for_marking)
end