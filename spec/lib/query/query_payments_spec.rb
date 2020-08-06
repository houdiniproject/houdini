# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'support/payments_for_a_payout'

describe QueryPayments do

  before :each do
    @nonprofit = force_create(:nonprofit, name: "npo1");
    @supporters = [ force_create(:supporter, name: "supporter-0", nonprofit: @nonprofit),
                    force_create(:supporter, name: "supporter-1", nonprofit: @nonprofit)]

    @payments = [force_create(:payment, gross_amount: 1000, fee_total: 99, net_amount: 901, supporter: @supporters[0], nonprofit:@nonprofit),
                 force_create(:payment, gross_amount: 2000, fee_total: 22, net_amount: 1978, supporter: @supporters[1], nonprofit:@nonprofit)]
    @bank_account = force_create(:bank_account, name: 'bank1', nonprofit: @nonprofit)
  end

  describe '.ids_for_payout' do
    before(:each) {
      Timecop.freeze(2020,5,5)
    }
    after(:each) {
      Timecop.return
    }



    describe 'no date provided' do
      include_context 'payments for a payout' do
        let(:np) { @nonprofit }
        let(:date_for_marking) {Time.now}

      end

      it 'np is invalid' do
        expect(QueryPayments.ids_for_payout(686826812658102751098754)).to eq []
      end

      it 'works without a date provided' do
        all_payments

        result = QueryPayments.ids_for_payout(np.id)

        payments_for_payout = Set.new()
        @expect_marked[:charges].each {|c|
          c.reload()
          payments_for_payout.add(c.payment.id)
        }

        @expect_marked[:disputes].each {|d|
          d.reload()
          payments_for_payout.add(d.payment.id)
        }

        @expect_marked[:refunds].each {|r|
          r.reload()
          payments_for_payout.add(r.payment.id)
        }

        expect(result).to match_array(payments_for_payout)
      end
    end

    describe 'with date provided' do
      include_context 'payments for a payout' do
        let(:np) { @nonprofit }
        let(:date_for_marking) {Time.now - 1.day}

      end

      it 'np is invalid' do
        expect(QueryPayments.ids_for_payout(686826812658102751098754)).to eq []
      end

      it 'works with a date provided' do
        all_payments

        result = QueryPayments.ids_for_payout(np.id, {date: Time.now - 1.day})

        payments_for_payout = Set.new()
        @expect_marked[:charges].each {|c|
          c.reload()
          payments_for_payout.add(c.payment.id)
        }

        @expect_marked[:disputes].each {|d|
          d.reload()
          payments_for_payout.add(d.payment.id)
        }

        @expect_marked[:refunds].each {|r|
          r.reload()
          payments_for_payout.add(r.payment.id)
        }

        expect(result).to match_array(payments_for_payout)
      end
    end



  end

  describe '.get_payout_total'do
    include_context 'payments for a payout' do
      let(:np) { @nonprofit }
      let(:date_for_marking) {Time.now}

    end
    it 'gives empty payout result if no payments provided' do
      result = QueryPayments.get_payout_totals([])

      expected = {'gross_amount' => 0, 'fee_total' => 0, 'net_amount' => 0}
      expect(result).to eq expected
    end

    it 'gives correct payout info' do
      all_payments
      result = QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(np.id))
      expected  = {gross_amount: 5500, fee_total: -1200, net_amount: 4300, count: 8}.with_indifferent_access

      expect(result.with_indifferent_access).to eq expected
    end


  end

  describe '.for_payout' do

    before(:each) do
      gross = @payments.map{|h| h['gross_amount']}.sum
      fees = @payments.map{|h| h['fee_total']}.sum
      net = @payments.map{|h| h['net_amount']}.sum
      @payout = force_create(:payout, gross_amount: gross, fee_total: fees, net_amount: net, nonprofit: @nonprofit)
      @payment_payouts = @payments.map {|p| force_create(:payment_payout, payment: p, payout:@payout)}

      @result = QueryPayments.for_payout(@nonprofit['id'], @payout['id'])
    end

    it 'sets the correct headers' do
      expect(@result.first).to eq(["date", "gross_total", "fee_total", "net_total", "bank_name", "status"])
    end

    it 'sets the correct payout data' do
      expect(@result[1].count).to eq(6) # TODO
    end
    
    it 'sets the payment headers', :pending => true do
      expect(@result[3]).to eq(["Date", "Gross Amount", "Fee Total", "Net Amount", "Type", "Payment ID", "Last Name", "First Name", "Full Name", "Organization", "Email", "Phone", "Address", "City", "State", "Postal Code", "Country", "Anonymous?", "Designation", "Honorarium/Memorium", "Comment", "Campaign", "Campaign Gift Level", "Event"])
    end

    it 'sets the correct payment data', :pending => true do
      expect(@result[4].count).to eq 24
    end
  end

  describe '.for_export_enumerable' do
    it 'finishes two payment export' do
      rows = QueryPayments::for_export_enumerable(@nonprofit.id, {}).to_a

      headers = MockHelpers.payment_export_headers

      expect(rows.length).to eq(3)
      expect(rows[0]).to eq(headers)

    end
  end

  describe '.full_search' do

    include_context :shared_rd_donation_value_context
    before(:each) {
      nonprofit.stripe_account_id = Stripe::Account.create()['id']
      nonprofit.save!
      card.stripe_customer_id = 'some other id'
      cust = Stripe::Customer.create()
      card.stripe_customer_id = cust['id']
      card.save!
      expect(Stripe::Charge).to receive(:create).exactly(3).times.and_wrap_original {|m, *args| a = m.call(*args);
      @stripe_charge_id = a['id']
      a
      }

    }

    let(:charge_amount_small) { 200}
    let(:charge_amount_medium) { 400}
    let(:charge_amount_large) { 600}

    def generate_donation(h)
      token = h[:token]
      date = h[:date]
      amount = h[:amount]

      input = {amount: amount,
               nonprofit_id: nonprofit.id,
               supporter_id: supporter.id,
               token: token,

               date: date,
               dedication: 'dedication',
               designation: 'designation'}
      if h[:event_id]
        input[:event_id] = h[:event_id]
      end

      if h[:campaign_id]
        input[:campaign_id] = h[:campaign_id]
      end

      InsertDonation.with_stripe(input)
    end

    describe 'general donations' do
      let(:donation_result_yesterday) {
          generate_donation(amount: charge_amount_small,

                                     token: source_tokens[0].token,
                                     date: (Time.now - 1.day).to_s)


      }

      let(:donation_result_today) {

          generate_donation(amount:  charge_amount_medium,

                                     token: source_tokens[1].token,

                                     date: (Time.now).to_s
                             )
      }

      let(:donation_result_tomorrow) {

          generate_donation(amount: charge_amount_large,

                                     token: source_tokens[2].token,
                                     date: (Time.now - 1.day).to_s
                            )

      }

      let (:first_refund_of_yesterday) {
        charge =  donation_result_yesterday['charge']

          InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)

      }

      let(:second_refund_of_yesterday) {
        charge =  donation_result_yesterday['charge']

        InsertRefunds.with_stripe(charge.attributes, {amount: 50}.with_indifferent_access)

      }


      it 'empty filter returns all' do
        donation_result_yesterday
        donation_result_today
        donation_result_tomorrow
        first_refund_of_yesterday
        second_refund_of_yesterday

        result = QueryPayments::full_search(nonprofit.id, {})

        expect(result[:data].count).to eq 5
      end







    end

    describe 'event donations' do
      let(:donation_result_yesterday) {
        generate_donation(amount: charge_amount_small,
                          event_id: event.id,
                          token: source_tokens[0].token,
                          date: (Time.now - 1.day).to_s)


      }

      let(:donation_result_today) {

        generate_donation(amount:  charge_amount_medium,
                          event_id: event.id,
                          token: source_tokens[1].token,

                          date: (Time.now).to_s
        )
      }

      let(:donation_result_tomorrow) {

        generate_donation(amount: charge_amount_large,

                          token: source_tokens[2].token,
                          date: (Time.now - 1.day).to_s
        )

      }

      let (:first_refund_of_yesterday) {
        charge =  donation_result_yesterday['charge']

        InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)

      }

      let(:second_refund_of_yesterday) {
        charge =  donation_result_yesterday['charge']

        InsertRefunds.with_stripe(charge.attributes, {amount: 50}.with_indifferent_access)

      }

      it 'search includes refunds for that event ' do
        donation_result_yesterday
        donation_result_today
        donation_result_tomorrow
        first_refund_of_yesterday
        second_refund_of_yesterday

        result = QueryPayments::full_search(nonprofit.id, {event_id: event.id})

        expect(result[:data].count).to eq 4
        expect(result[:data]).to_not satisfy {|i| i.any?{|j| j['id'] == donation_result_tomorrow['payment']['id']}}
      end
    end

    describe 'campaign donations' do
      let(:donation_result_yesterday) {
        generate_donation(amount: charge_amount_small,
                          campaign_id:campaign.id,
                          token: source_tokens[0].token,
                          date: (Time.now - 1.day).to_s)


      }

      let(:donation_result_today) {

        generate_donation(amount:  charge_amount_medium,
                          campaign_id:campaign.id,
                          token: source_tokens[1].token,

                          date: (Time.now).to_s
        )
      }

      let(:donation_result_tomorrow) {

        generate_donation(amount: charge_amount_large,

                          token: source_tokens[2].token,
                          date: (Time.now - 1.day).to_s
        )

      }

      let (:first_refund_of_yesterday) {
        charge =  donation_result_yesterday['charge']

        InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)

      }

      let(:second_refund_of_yesterday) {
        charge =  donation_result_yesterday['charge']

        InsertRefunds.with_stripe(charge.attributes, {amount: 50}.with_indifferent_access)

      }


      it 'search includes refunds for that campaign ' do
        donation_result_yesterday
        donation_result_today
        donation_result_tomorrow
        first_refund_of_yesterday
        second_refund_of_yesterday

        result = QueryPayments::full_search(nonprofit.id, {campaign_id: campaign.id})

        expect(result[:data].count).to eq 4
        expect(result[:data]).to_not satisfy {|i| i.any?{|j| j['id'] == donation_result_tomorrow['payment']['id']}}
      end
    end

  end

  describe 'balances and payouts' do 
    let(:nonprofit) {create(:nonprofit)}
    let(:charge_available) {  create(:charge, nonprofit: nonprofit, amount: 100, status: 'available', payment: force_create(:payment, nonprofit: nonprofit, gross_amount: 100))}
    let(:charge_paid) {  create(:charge, nonprofit: nonprofit, amount: 200, status: 'paid', payment: force_create(:payment, nonprofit: nonprofit, gross_amount: 200))}
    let(:charge_pending) { create(:charge, nonprofit: nonprofit, amount: 400, status: 'pending', payment: force_create(:payment, nonprofit: nonprofit, gross_amount: 400))}
    let(:refund_disbursed) { create(:refund, amount: 800, disbursed: true, payment: force_create(:payment, nonprofit: nonprofit, gross_amount: -800))}
    let(:refund) { create(:refund, amount: 1600, payment: force_create(:payment, nonprofit: nonprofit, gross_amount: -1600))}
    let(:legacy_dispute_paid) { create(:dispute,  gross_amount: 3200, status: :lost_and_paid, payment: force_create(:payment, nonprofit: nonprofit, gross_amount: -3200))}
    let(:legacy_dispute_won) { create(:dispute, gross_amount: 6400, status: :won)}
    let(:legacy_dispute_lost) { create(:dispute, gross_amount: 25600, status: :lost, payment: force_create(:payment, nonprofit: nonprofit, gross_amount: -25600))}
    let(:dispute_lost) do 
      d = create(:dispute, 
        gross_amount: 12800,
        net_amount: -14300,
        status: :lost,
        payment: create(:payment, 
          nonprofit: nonprofit, 
          gross_amount: -12800,
          fee_total: -1500,
          net_amount: -14300)
      )

      d.create_commitchange_modern_dispute
      d
    end
    let(:dispute_won) do 
      d = create(:dispute, 
        gross_amount: 51200,
        net_amount: 0,
        status: :won,
        payment: create(:payment, 
          nonprofit: nonprofit, 
          gross_amount: -51200,
          fee_total: -1500,
          net_amount: -52700)
        
      )

      d.create_commitchange_modern_dispute
      d
    end

    let(:dispute_paid) do 
      d = create(:dispute,
        gross_amount: 102800,
        net_amount: -104300,
        status: :lost_and_paid,
        payment: create(:payment, 
          nonprofit: nonprofit, 
          gross_amount: -102800,
          fee_total: -1500,
          net_amount: -104300)
      ) 

      d.create_commitchange_modern_dispute
      d
    end

    let(:dispute_under_review) do 
      d = create(:dispute,
        gross_amount: 205600,
        net_amount: -207100,
        status: :under_review,
        payment: create(:payment, 
          nonprofit: nonprofit, 
          gross_amount: -205600,
          fee_total: -1500,
          net_amount: -207100)
      )
      d.create_commitchange_modern_dispute
      d
    end

    let(:dispute_needs_response) do 
      d = create(:dispute,
        gross_amount: 512000,
        net_amount: -513500,
        status: :needs_response,
        payment: create(:payment, 
          nonprofit: nonprofit, 
          gross_amount: -512000,
          fee_total: -1500,
          net_amount: -513500)
      )
      d.create_commitchange_modern_dispute
      d
    end


    let(:nonprofit_balances) { QueryPayments.nonprofit_balances(nonprofit.id)}

    before(:each) do
      nonprofit
      charge_available
      charge_paid
      charge_pending
      refund_disbursed
      refund
      legacy_dispute_paid
      legacy_dispute_lost
      legacy_dispute_won
      dispute_lost
      dispute_won
      dispute_paid
      dispute_under_review
      dispute_needs_response
    end

    describe ".nonprofit_balances" do 
      it 'has a pending balance of 400' do
        expect(nonprofit_balances['pending_gross']).to eq 400
      end

      it 'has an available balance of -762000' do
        expect(nonprofit_balances['available_gross']).to eq -762000
      end

      it 'has one charge  as count_available' do
        expect(nonprofit_balances['count_available']).to eq 1
      end

      it 'has one refund as count_refunds' do
        expect(nonprofit_balances['count_refunds']).to eq 1
      end

      it 'has four disputes as count_disputes' do
        expect(nonprofit_balances['count_disputes']).to eq 4
      end
    end
    describe '.ids_for_payouts' do 
      let(:ids_for_payouts) {QueryPayments.ids_for_payout(nonprofit.id)}
      it 'contains the proper ids to consider in ids_for_payout' do 
        expect(ids_for_payouts)
      end
    end
  end
end
