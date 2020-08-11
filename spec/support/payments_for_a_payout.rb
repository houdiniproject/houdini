# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
shared_context 'payments for a payout' do

  let(:today) { Time.new(2020,5,5, 1) }
  let(:yesterday) {Time.new(2020,5,4, 1)}
  let(:two_days_ago) {Time.new(2020,5,3, 1)}
  
  # let(:all_payments) {
  #   payment_with_charge_to_output
  #   partial_refunded_payment
  #   refunded_payment
  #   disputed_payment
  #   late_payment
  #   paid_out_payment
  #   paid_out_refund
  #   paid_out_dispute
  #   other_np_payment
  # }
  let(:eb_two_days_ago) {EntityBuilder.new(two_days_ago, nonprofit)}
  let(:entities_two_days_ago){eb_two_days_ago.entities}
  let(:payments_two_days_ago){eb_two_days_ago.payments}
  let(:available_payments_two_days_ago) { eb_two_days_ago.available_payments}

  let(:eb_yesterday) {EntityBuilder.new(yesterday, nonprofit) }
  let(:entities_yesterday) {eb_yesterday.entities}
  let(:payments_yesterday){eb_yesterday.payments}
  let(:available_payments_yesterday) { eb_yesterday.available_payments}

  let(:eb_today) {EntityBuilder.new(today, nonprofit) }
  let(:entities_today) {eb_today.entities}
  let(:payments_today) {eb_today.payments}
  let(:available_payments_today) { eb_today.available_payments}
  
  #net amount: 1600
  # let(:payment_with_charge_to_output) {
  #   p = create_marked_payment
  #   create_marked_charge(payment: p, amount: 2000, fee: -400, status: 'available')
  #   return p
  # }

  # #net amount: 1100
  # let(:partial_refunded_payment) {
  #   p = create_marked_payment
  #   c = create_marked_charge(payment: p, amount: 2000, fee: -400, status: 'available')

  #   refund_payment = create_marked_payment(gross_amount: -500, fee_total: 0, net_amount: -500)
  #   create_marked_refund(charge: c, payment: refund_payment, amount: 500)
  #   return p
  # }

  # #net amount: 0
  # let(:refunded_payment) {
  #   p = create_marked_payment
  #   c = create_marked_charge(payment: p, amount: 2000, status: 'available')
  #   refund_payment = create_marked_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
  #   create_marked_refund(charge: c, payment: refund_payment, amount: 2000, disbursed: false)
  #   return p
  # }

  # #net amount: 0
  # let(:disputed_payment) {
  #   p = create_marked_payment
  #   c = create_marked_charge(payment: p, amount: 2000, status: 'available')

  #   p2 = create_marked_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
  #   create_marked_dispute(charge: c, payment: p2, gross_amount: 2000, status: 'lost')
  #   return p
  # }

  # #net amount: 1600
  # let(:late_payment) {
  #   is_this_marked = Time.now.beginning_of_day <= date_for_marking.beginning_of_day
  #   p = create_payment(date: Time.now, marked: is_this_marked)
  #   c = charge_create(payment: p, amount: 2000, status: 'available', marked: is_this_marked)

  #   return p
  # }

  # #net amount: 0
  # let(:paid_out_payment) {
  #   p = create_payment
  #   c = charge_create(payment: p, amount: 2000, status: 'disbursed')
  #   return p
  # }

  # #net amount: 0
  # let(:paid_out_refund) {
  #   p = create_payment
  #   c = charge_create(payment: p, amount: 2000, status: 'disbursed')
  #   refunded_payment = create_payment(gross_amount: -2000, fee_total: 400, net_amount: -1600)
  #   refund = create_refund(payment: refunded_payment, disbursed: true)
  #   return p
  # }


  # #net amount: 0
  # let(:paid_out_dispute) {
  #   p = create_payment
  #   c = charge_create(payment: p, amount: 2000, status: 'disbursed')
  #   # dispute_payment = 
  #   dispute = create_dispute(charge: c, gross_amount: 2000, status: 'lost')
  #   # dispute.dispute_transactions.create(payment: 
  #   return p
  # }

  # let(:other_np_payment) {
  #   p = create_payment(nonprofit: force_create(:nonprofit))
  #   charge_create(payment: p, amount: 2000, fee: -400, status: 'available')
  #   return p
  # }

  # def create_marked_payment(args = {})
  #   return create_payment(args.merge({marked: true}))
  # end

  # def create_payment(args = {})
  #   expect_payment = args[:marked]
  #   p = force_create(:payment, {nonprofit: np, date: Time.now - 1.day, gross_amount: 2000, fee_total: -400, net_amount: 1600}.merge(args.except(:marked)))
  #   if (expect_payment)
  #     @expect_marked[:payouts_records].push(p)
  #   end
  #   p
  # end

  # def create_marked_refund(args = {})
  #   create_refund(args.merge({marked: true}))
  # end


  # def create_refund(args = {})
  #   expect_refund = args[:marked]
  #   r = force_create(:refund, args.except(:marked))
  #   if (expect_refund)
  #     @expect_marked[:refunds].push(r)
  #   end
  #   r
  # end

  # def create_marked_charge(args = {})
  #   charge_create(args.merge({marked: true}))
  # end

  # def charge_create(args = {})
  #   expect_charge = args[:marked]
  #   c = force_create(:charge, args.except(:marked))
  #   if (expect_charge)
  #     @expect_marked[:charges].push(c)
  #   end
  #   c
  # end

  # def create_marked_dispute(args = {})
  #   create_dispute(args.merge({marked: true}))
  # end

  # def create_dispute(args = {})
  #   expect_dispute = args[:marked]
  #   d = force_create(:dispute, args.except(:marked))
  #   if (expect_dispute)
  #     @expect_marked[:disputes].push(d)
  #   end
  #   d
  # end


  #provide let(date_for_marking)

  class EntityBuilder
    include FactoryBot::Syntax::Methods
    include FactoryBotExtensions
    attr_accessor :entities
    def initialize(time, nonprofit, other_nonprofit=nil)
      @time = time

      @nonprofit = nonprofit
      @other_nonprofit = other_nonprofit
      @entities = build_entities
    end

    def payments
      entities.map do |k,v|
        output = nil
        if (v.is_a? Charge)
          output = [v.payment]
        elsif (v.is_a? Refund)
          output = [v.payment, v.charge.payment]
        elsif (v.is_a? Dispute)
          output = v.dispute_transactions.map{|dt| dt.payment}.concat([v.charge.payment])
        end
        output
      end.flatten.uniq
    end

    def available_payments
      entities.map do |k,v|
        output = []
        if (v.is_a?(Charge) && v.status == 'available')
          output  << v.payment
        elsif (v.is_a? Refund)
          if !v.disbursed
            output << v.payment
          end
          if (v.charge.status == 'available')
            output << v.charge.payment
          end
        elsif (v.is_a? Dispute)
          if (v.charge.status == 'available')
            output << v.charge.payment
          end
          output = output.concat(v.dispute_transactions.select{|i| !i.disbursed}.map{|dt|dt.payment})
        end
        output
      end.flatten.uniq
    end

    private
    def build_entities
      output = {}
      Timecop.freeze(@time) do
        output[:charge_available] = charge_available
        output[:charge_paid] = charge_paid
        output[:charge_pending] = charge_pending
        output[:refund_disbursed] = refund_disbursed
        output[:refund] = refund
        output[:legacy_dispute_paid] = legacy_dispute_paid
        output[:legacy_dispute_won] = legacy_dispute_won
        output[:legacy_dispute_lost] = legacy_dispute_lost
        output[:dispute_lost] = dispute_lost
        output[:dispute_won] = dispute_won
        output[:dispute_paid] = dispute_paid
        output[:dispute_under_review] = dispute_under_review
        output[:dispute_needs_response] = dispute_needs_response
        # output[:partial_dispute_lost] = partial_dispute_lost
        # output[:partial_dispute_won] = partial_dispute_won
        # output[:partial_refund] = partial_refund
      end
      output
    end

    private 
    
    #net 100
    def charge_available
      charge_create(gross_amount:100, status: 'available')
    end

    # net 0
    def charge_paid
      charge_create(gross_amount:200, status: 'paid')
    end

    # 400 pending
    def charge_pending 
      charge_create(gross_amount:400, status: 'pending')
    end

    # net 0
    def refund_disbursed
      refund_create({gross_amount:800, original_charge_args: {status: 'paid'}, disbursed: true})
    end

    # net 0
    def refund
      refund_create({gross_amount:1600, original_charge_args:{status: 'available'}})
    end

    # net 0
    def legacy_dispute_paid
      d= dispute_create(gross_amount:3200, status: :lost, original_charge_args: {status: 'paid'})
      d.dispute_transactions.create(**dispute_transaction_args_create(-3200, 0), disbursed: true)
      d
    end

    # net 6400
    def legacy_dispute_won
      d = dispute_create(gross_amount:6400, status: :won)
    end

    # net 0
    def legacy_dispute_lost
      d = dispute_create(gross_amount:25600, status: :lost)
      d.dispute_transactions.create(**dispute_transaction_args_create(-25600, 0))
      d
    end
    
    # net -1500
    def dispute_lost
      d = dispute_create(gross_amount:12800, status: :lost)
      d.dispute_transactions.create(**dispute_transaction_args_create(-12800, -1500))
      d
    end

    # net 51200
    def dispute_won
      d = dispute_create({gross_amount: 51200, status: :won})
      d.dispute_transactions.create(**dispute_transaction_args_create(-51200, -1500))
      d.dispute_transactions.create(**dispute_transaction_args_create(51200, 1500))
      d
    end

    # net 0
    def dispute_paid
      d = dispute_create(gross_amount:102800, status: :lost, original_charge_args: {status: :paid})
      d.dispute_transactions.create(disbursed: true, **dispute_transaction_args_create(-102800, -1500))
      d
    end

    # net -1500
    def dispute_under_review
      d = dispute_create(gross_amount:205600, status: :under_review)
      d.dispute_transactions.create(**dispute_transaction_args_create(-205600, -1500))
      d
    end

    # net -1500
    def dispute_needs_response
      d = dispute_create(gross_amount:512000, status: :needs_response)
      d.dispute_transactions.create(**dispute_transaction_args_create(-512000, -1500))
      d
    end
  

    def refund_create(**args)

      gross_amount = args[:gross_amount]
      fee_total = args[:fee_total] || 0
      
      temp_charge_args = {gross_amount:gross_amount, fee_total: fee_total }
      temp_charge_args = temp_charge_args.merge(args[:original_charge_args]) if args[:original_charge_args]


      orig_charge = charge_create(status: 'available', **temp_charge_args)

      force_create(:refund, amount: args[:gross_amount], charge: orig_charge, payment: payment_create( gross_amount:-1 * gross_amount, fee_total: fee_total || 0, net_amount:  (-1 * gross_amount) - fee_total), **args.except(:gross_amount, :original_charge_args))
    end

    def dispute_create(**args)
      gross_amount = args[:gross_amount]
      temp_charge_args = {gross_amount:gross_amount }
      temp_charge_args = temp_charge_args.merge(args[:original_charge_args]) if args[:original_charge_args]
      orig_charge = charge_create(status: 'available', **temp_charge_args)
      force_create(:dispute, gross_amount: gross_amount, charge: orig_charge, **args.except(:original_charge_args))
    end

    def dispute_transaction_args_create(gross_amount, fee_total)
      {gross_amount: gross_amount, fee_total: fee_total, 
        payment: payment_create(gross_amount:gross_amount, fee_total: fee_total, net_amount: gross_amount + fee_total,
          nonprofit: @nonprofit )}
    end

    def charge_create( **args)
      gross_amount = args[:gross_amount]
      fee_total = args[:fee_total] || 0
      other_args = args.except(:gross_amount, :fee_total)
      force_create(:charge, nonprofit:@nonprofit, amount: gross_amount, 
        payment: payment_create(gross_amount: gross_amount, fee_total: fee_total, net_amount: gross_amount + fee_total), **other_args)
    end

    def payment_create(**args)
      force_create(:payment, nonprofit:@nonprofit, date: @time, **args)
    end


  end
end