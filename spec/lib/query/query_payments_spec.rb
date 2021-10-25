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
    around(:each) do |example|
      Timecop.freeze(2020,5,5) do
        example.run
      end
    end

    describe 'no date provided' do
      include_context 'payments for a payout' do
        let(:nonprofit) { @nonprofit }
      end
      let!(:payments) {payments_two_days_ago.concat(payments_yesterday).concat(payments_today)}

      let!(:expected_payments) {available_payments_two_days_ago.concat(available_payments_yesterday).concat(available_payments_today)}
      
      it 'np is invalid' do
        expect(QueryPayments.ids_for_payout(686826812658102751098754)).to eq []
      end

      it 'works without a date provided' do
        result = QueryPayments.ids_for_payout(nonprofit.id)
        expect(result).to match_array(expected_payments.map{|i| i.id})
      end
    end

    describe 'with date provided' do
      include_context 'payments for a payout' do
        let(:nonprofit) { @nonprofit }
      end
      let!(:payments) {payments_two_days_ago.concat(payments_yesterday).concat(payments_today)}

      let!(:expected_payments) {available_payments_two_days_ago.concat(available_payments_yesterday)}

      it 'np is invalid' do
        expect(QueryPayments.ids_for_payout(686826812658102751098754)).to eq []
      end

      it 'works with a date provided' do
        result = QueryPayments.ids_for_payout(nonprofit.id, {
          date: Time.current - 1.day + 1.hour #the payments are all at 1AM
        })
        expect(result).to match_array(expected_payments.map{|i| i.id})
      end
    end



  end

  describe '.get_payout_total'do
    around(:each) do |example|
      Timecop.freeze(2020,5,5) do
        example.run
      end
    end
    include_context 'payments for a payout' do
      let(:nonprofit) { @nonprofit }

    end
    
    it 'gives empty payout result if no payments provided' do
      result = QueryPayments.get_payout_totals([])

      expected = {'gross_amount' => 0, 'fee_total' => 0, 'net_amount' => 0}
      expect(result).to eq expected
    end

    it 'gives correct payout info' do
      entities_yesterday
      result = QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(nonprofit.id))
      expected  = {gross_amount: 57700, fee_total: -4500, net_amount: 53200, count: 15}.with_indifferent_access

      expect(result.with_indifferent_access).to eq expected
    end


  end

  describe '.full_search' do

    include_context :shared_rd_donation_value_context
    before(:each) do
      nonprofit.stripe_account_id = Stripe::Account.create()['id']
      nonprofit.save!
      cust = Stripe::Customer.create()
      card.stripe_customer_id = cust.id
      source = Stripe::Customer.create_source(cust.id, {source: StripeMock.generate_card_token(brand: 'Visa', country: 'US')})
      card.stripe_card_id = source.id
      card.save!
      expect(Stripe::Charge).to receive(:create).exactly(3).times.and_wrap_original {|m, *args| a = m.call(*args);
        @stripe_charge_id = a['id']
        a
      }

    end

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

      d = InsertDonation.with_stripe(input)
      c = Charge.find(d['charge']['id'])
      c.created_at = date
      c.updated_at = date
      c.save!
      d
    end


    let(:amount_of_fees_to_refund) { 0}
    let(:stripe_app_fee_refund) {  Stripe::ApplicationFeeRefund.construct_from({amount: amount_of_fees_to_refund, id: 'app_fee_refund_1'})}
    let(:stripe_refund) { Stripe::Refund.construct_from({id: 'refund_1'})}
    
    let(:perform_stripe_refund_result) do
      {stripe_refund: stripe_refund, stripe_app_fee_refund: amount_of_fees_to_refund > 0 ? stripe_app_fee_refund : nil}
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
                                     date: (Time.now + 1.day).to_s
                            )

      }
      let(:charge_result_yesterday) {
        Charge.find(donation_result_yesterday['charge']['id'])
      }

      let (:first_refund_of_yesterday) {
        charge =  charge_result_yesterday
        expect(InsertRefunds).to receive(:perform_stripe_refund).with(
          nonprofit_id:nonprofit.id, refund_data:{
            'amount' => 100,
            'charge'=> charge.stripe_charge_id
          }, charge_date: charge.created_at).and_return(perform_stripe_refund_result)
        expect(InsertActivities).to receive(:for_refunds)
          InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)

      }

      let(:second_refund_of_yesterday) {
        charge =  charge_result_yesterday
        expect(InsertRefunds).to receive(:perform_stripe_refund).with(
          nonprofit_id: nonprofit.id, refund_data:{
            'amount' => 50,
            'charge'=> charge.stripe_charge_id
          }, charge_date: charge.created_at).and_return(perform_stripe_refund_result)
        expect(InsertActivities).to receive(:for_refunds)
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

      context 'considering the nonprofit timezone on the query result' do
        before do
          donation_result_today
          first_refund_of_yesterday
          second_refund_of_yesterday
        end

        it 'when the nonprofit does not have a timezone it considers UTC as default' do
          donation_result_tomorrow
          result = QueryPayments::full_search(nonprofit.id, {})
          expect(result[:data].first['date']).to eq (Time.now).to_s
        end

        context 'when the nonprofit has a timezone' do
          before do
            nonprofit.update_attributes(timezone: 'America/New_York')
            allow(QuerySourceToken)
              .to receive(:get_and_increment_source_token)
              .and_return(source_tokens[0])
          end

          it 'shows the corresponding time' do
            donation_result_tomorrow
            result = QueryPayments::full_search(nonprofit.id, {})
            expect(result[:data].first['date']).to eq ((Time.now) - 4.hours).to_s
          end

          it 'finds the payments on dates after the specified dates' do
            donation_result_tomorrow
            result = QueryPayments::full_search(nonprofit.id, { after_date: Time.now - 4.hours })
            expect(result[:data].count).to eq 5
          end

          it 'finds the payments on dates before the specified dates' do
            donation_result_tomorrow
            result = QueryPayments::full_search(nonprofit.id, { before_date: Time.now })
            expect(result[:data].count).to eq 5
          end

          it 'finds the payments of an specific year' do
            # creating a payment at 1 AM UTC from january 2020
            # should not be included in the 2020 query if we are at America/New_York
            Timecop.freeze(2020,1,1,1,0,0, "+00:00")
            donation =
              generate_donation(
                amount: charge_amount_large,
                token: source_tokens[2].token,
                date: Time.now.to_s
              )
            result_for_2020 = QueryPayments::full_search(nonprofit.id, { year: '2020' })
            result_for_2019 = QueryPayments::full_search(nonprofit.id, { year: '2019' })
            expect(result_for_2019[:data].count).to eq 1
            expect(result_for_2020[:data].count).to eq 4
          end
        end
      end

      context 'filtering by donation or supporter fields' do
        let(:input) {{
          amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          token: source_tokens[4].token,
          date: (Time.now - 1.day).to_s,
          comment: 'donation comment',
          dedication: 'dedication',
          designation: 'designation'
        }}

        it 'searching for a payment using the donation comment' do
          InsertDonation.with_stripe(input)
          donation_result_tomorrow
          donation_result_yesterday

          result = QueryPayments::full_search(nonprofit.id, { search: 'donation comment' })
          expect(result[:data].count).to eq 1
        end

        it 'searching for a payment using the supporter name' do
          InsertDonation.with_stripe(input)
          donation_result_tomorrow
          donation_result_yesterday

          result = QueryPayments::full_search(nonprofit.id, { search: supporter.name })
          expect(result[:data].count).to eq 3
        end
      end

      context 'when filtering by payment id' do
        let(:input) {{
          amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          token: source_tokens[4].token,
          date: (Time.now - 1.day).to_s,
          comment: 'donation comment',
          dedication: 'dedication',
          designation: 'designation'
        }}

        it 'returns one result' do
          InsertDonation.with_stripe(input)
          donation_result_tomorrow
          donation_result_yesterday

          result = QueryPayments::full_search(nonprofit.id, { search: Payment.last.id })
          expect(result[:data].count).to eq 1
        end
      end

      context 'when the search includes a number that is not a payment ID' do
        let(:input) {{
          amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          token: source_tokens[4].token,
          date: (Time.now - 1.day).to_s,
          comment: '2020',
          dedication: 'dedication',
          designation: 'designation'
        }}

        it 'returns one result' do
          InsertDonation.with_stripe(input)
          donation_result_tomorrow
          donation_result_yesterday

          result = QueryPayments::full_search(nonprofit.id, { search: 2020 })
          expect(result[:data].count).to eq 1
        end
      end

      context 'when searching by supporter phone number' do
        it 'finds when using character filled phone number' do 
          donation_result_yesterday
          donation_result_today
          donation_result_tomorrow
          supporter.phone = "+1 (920) 915-4980"
          supporter.save!
          
          result = QueryPayments::full_search(nonprofit.id,  { search: "+1(920) 915*4980a" })
          expect(result[:data].count).to eq 3
        end
  
        it 'finds when using spaced phone number' do
          donation_result_yesterday
          donation_result_today
          donation_result_tomorrow
          supporter.phone = "+1 (920) 915-4980"
          supporter.save!
          result = QueryPayments::full_search(nonprofit.id, { search: "1 920 915 4980" })
          expect(result[:data].count).to eq 3
        end
  
        it 'finds when using nonspaced phone number' do 
          donation_result_yesterday
          donation_result_today
          donation_result_tomorrow
          supporter.phone = "+1 (920) 915-4980"
          supporter.save!
          result = QueryPayments::full_search(nonprofit.id, { search: "19209154980" })
          expect(result[:data].count).to eq 3
        end
  
        it 'does not find based on partial phone number' do
          donation_result_yesterday
          donation_result_today
          donation_result_tomorrow
          result = QueryPayments::full_search(nonprofit.id, { search: "9209154980" })
          expect(result[:data].count).to eq 0 # just the headers
        end

        it 'does not find payments with blank phone numbers accidentally' do
          donation_result_yesterday
          donation_result_today
          donation_result_tomorrow
          supporter.phone = " "
          supporter.save!
          result = QueryPayments::full_search(nonprofit.id,  { search: "A search term" })
          expect(result[:data].count).to eq 0
          
        end
      end

      context 'when filtering by anonymous or not anonymous donations' do
        context 'when supporter and donation are not anonymous' do
          context 'when not filtering' do
            it 'finds all results' do
              donation_result_yesterday
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: '' })
              expect(result[:data].count).to eq 3
            end
          end

          context 'when filtering by anonymous' do
            it 'does not find results' do
              donation_result_yesterday
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'true' })
              expect(result[:data].count).to eq 0
            end
          end

          context 'when filtering by not-anonymous' do
            it 'finds all results' do
              donation_result_yesterday
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'false' })
              expect(result[:data].count).to eq 3
            end
          end
        end

        context 'when supporter is anonymous but donation is not' do
          before do
            supporter.anonymous = true
            supporter.save!
          end

          context 'when not filtering' do
            it 'finds all results' do
              donation_result_yesterday
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: '' })
              expect(result[:data].count).to eq 3
            end
          end

          context 'when filtering by anonymous' do
            it 'finds all results' do
              donation_result_yesterday
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'true' })
              expect(result[:data].count).to eq 3
            end
          end

          context 'when filtering by not-anonymous' do
            it 'does not find results' do
              donation_result_yesterday
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'false' })
              expect(result[:data].count).to eq 0
            end
          end
        end

        context 'when supporter is not anonymous but donation is' do
          let(:input) {{
            amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            token: source_tokens[4].token,
            date: (Time.now - 1.day).to_s,
            comment: 'donation comment',
            designation: 'designation',
            anonymous: true
          }}

          before do
            InsertDonation.with_stripe(input)
          end

          context 'when not filtering' do
            it 'finds all results' do
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: '' })
              expect(result[:data].count).to eq 3
            end
          end

          context 'when filtering by anonymous' do
            it 'finds all results' do
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'true' })
              expect(result[:data].count).to eq 1
            end
          end

          context 'when filtering by not-anonymous' do
            it 'does not find results' do
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'false' })
              expect(result[:data].count).to eq 2
            end
          end
        end

        context 'when supporter and donation are anonymous' do
          let(:input) {{
            amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            token: source_tokens[4].token,
            date: (Time.now - 1.day).to_s,
            comment: 'donation comment',
            designation: 'designation',
            anonymous: true
          }}

          before do
            supporter.anonymous = true
            supporter.save!
            InsertDonation.with_stripe(input)
          end

          context 'when not filtering' do
            it 'finds all results' do
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: '' })
              expect(result[:data].count).to eq 3
            end
          end

          context 'when filtering by anonymous' do
            it 'finds all results' do
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'true' })
              expect(result[:data].count).to eq 3
            end
          end

          context 'when filtering by not-anonymous' do
            it 'does not find results' do
              donation_result_today
              donation_result_tomorrow

              result = QueryPayments::full_search(nonprofit.id, { anonymous: 'false' })
              expect(result[:data].count).to eq 0
            end
          end
        end
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

      let(:charge_result_yesterday) {
        Charge.find(donation_result_yesterday['charge']['id'])
      }


      let (:first_refund_of_yesterday) {
        charge =  charge_result_yesterday
        expect(InsertRefunds).to receive(:perform_stripe_refund).with(
          nonprofit_id: nonprofit.id, refund_data:{
            'amount' => 100,
            'charge'=> charge.stripe_charge_id
          }, charge_date: charge.created_at).and_return(perform_stripe_refund_result)
        expect(InsertActivities).to receive(:for_refunds)
        InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)

      }

      let(:second_refund_of_yesterday) {
        charge =  charge_result_yesterday
        expect(InsertRefunds).to receive(:perform_stripe_refund).with(
          nonprofit_id:nonprofit.id, refund_data:{
            'amount' => 50,
            'charge'=> charge.stripe_charge_id
          }, charge_date: charge.created_at).and_return(perform_stripe_refund_result)
        expect(InsertActivities).to receive(:for_refunds)
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

      let(:charge_result_yesterday) {
        Charge.find(donation_result_yesterday['charge']['id'])
      }

      let(:donation_result_today) {

        generate_donation(amount:  charge_amount_medium,
                          campaign_id:campaign.id,
                          token: source_tokens[1].token,

                          date: (Time.now).to_s
        )
      }

      let(:charge_result_today) {
        Charge.find(donation_result_today['charge']['id'])
      }


      let(:donation_result_tomorrow) {

        generate_donation(amount: charge_amount_large,

                          token: source_tokens[2].token,
                          date: (Time.now - 1.day).to_s
        )

      }

      let(:charge_result_tomorrow) {
        Charge.find(donation_result_tomorrow['charge']['id'])
      }

      let(:amount_of_fees_to_refund) { 0}
      let(:stripe_app_fee_refund) {  Stripe::ApplicationFeeRefund.construct_from({amount: amount_of_fees_to_refund, id: 'app_fee_refund_1'})}
      let(:stripe_refund) { Stripe::Refund.construct_from({id: 'refund_1'})}
      
      let(:perform_stripe_refund_result) do
        {stripe_refund: stripe_refund, stripe_app_fee_refund: amount_of_fees_to_refund > 0 ? stripe_app_fee_refund : nil}
      end

      let(:first_refund_of_yesterday) {
        charge =  charge_result_yesterday
        expect(InsertRefunds).to receive(:perform_stripe_refund).with(
          nonprofit_id: nonprofit.id, refund_data: {
            'amount' => 100,
            'charge'=> charge.stripe_charge_id
          }, charge_date: charge.created_at).and_return(perform_stripe_refund_result)
          
        InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)

      }

      let(:second_refund_of_yesterday) {
        charge =  charge_result_yesterday
        expect(InsertRefunds).to receive(:perform_stripe_refund).with(
          nonprofit_id: nonprofit.id, refund_data: {
            'amount' => 50,
            'charge'=> charge.stripe_charge_id
          }, charge_date: charge.created_at).and_return(perform_stripe_refund_result)
        expect(InsertActivities).to receive(:for_refunds)
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
    include_context 'payments for a payout' do
      let(:nonprofit) {create(:nonprofit)}
    end
    # let(:charge_available) {  create(:charge, nonprofit: nonprofit, amount: 100, status: 'available', payment: force_create(:payment, nonprofit: nonprofit, gross_amount: 100, fee_total: 0, net_amount: 100))}
    # let(:charge_paid) {  create(:charge, nonprofit: nonprofit, amount: 200, status: 'paid', payment: force_create(:payment, nonprofit: nonprofit, gross_amount: 200, fee_total: 0, net_amount:200))}
    # let(:charge_pending) { create(:charge, nonprofit: nonprofit, amount: 400, status: 'pending', payment: force_create(:payment, nonprofit: nonprofit, gross_amount: 400, fee_total: 0, net_amount: 400))}
    # let(:refund_disbursed) { create(:refund, amount: 800, disbursed: true, payment: force_create(:payment, nonprofit: nonprofit, gross_amount: -800, fee_total: 0, net_amount:-800))}
    # let(:refund) { create(:refund, amount: 1600, payment: force_create(:payment, nonprofit: nonprofit, gross_amount: -1600, fee_total: 0, net_amount: -1600))}
    # let(:legacy_dispute_paid) do 
    #   dispute = crepaymentspute_lost) do 
    #    dispute = create(:dispute, gross_amount: -25600, status: :lost)
    #    dispute.dispute_transactions.create(gross_amount: -25600, payment: force_create(:payment, nonprofit: nonprofit, gross_amount: -25600,  fee_total: 0, net_amount: -25600))
    #    dispute
    # end

    # let(:dispute_lost) do 
    #   d = create(:dispute, 
    #     gross_amount: 12800,
    #     net_amount: -14300,
    #     status: :lost
    #   )

    #   d.dispute_transactions.create(gross_amount: -12800, fee_total: -1500, payment: 
    #     force_create(:payment, 
    #       nonprofit: nonprofit,  
    #       gross_amount: -12800,
    #       fee_total: -1500,
    #       net_amount: -14300)
    #     )
    #   d
    # end
    # let(:dispute_won) do 
    #   d = create(:dispute, 
    #     gross_amount: -51200,
    #     net_amount: 0,
    #     status: :won
    #   )
      
    #   d.dispute_transactions.create(gross_amount: -51200,
    #     fee_total: -1500,   
    #     payment: create(:payment, 
    #     nonprofit: nonprofit, 
    #     gross_amount: -51200,
    #     fee_total: -1500,
    #     net_amount: -52700))
    #   d.dispute_transactions.create(gross_amount: 51200,
    #     fee_total: 1500,   
    #     payment: create(:payment, 
    #     nonprofit: nonprofit, 
    #     gross_amount: 51200,
    #     fee_total: 1500,
    #     net_amount: 52700))
    #   d
    # end

    # let(:dispute_paid) do 
    #   d = create(:dispute,
    #     gross_amount: 102800,
    #     status: :lost,
    #     payment: create(:payment, 
    #       nonprofit: nonprofit, 
    #       gross_amount: -102800,
    #       fee_total: -1500,
    #       net_amount: -104300)
    #   )

    #   d.dispute_transactions.create(gross_amount: -102800,
    #     fee_total: -1500,
    #     payment: create(:payment, 
    #       nonprofit: nonprofit, 
    #       gross_amount: -102800,
    #       fee_total: -1500,
    #       net_amount: -104300),
    #     disbursed:true
    #   )

    #   d
    # end

    # let(:dispute_under_review) do 
    #   d = create(:dispute,
    #     gross_amount: 205600,
    #     net_amount: -207100,
    #     status: :under_review)
       
    #   d.dispute_transactions.create( gross_amount: -205600, fee_total: -1500, payment: create(:payment, 
    #     nonprofit: nonprofit, 
    #     gross_amount: -205600,
    #     fee_total: -1500,
    #     net_amount: -207100))
    #   d
    # end

    # let(:dispute_needs_response) do 
    #   d = create(:dispute,
    #     gross_amount: 512000,
    #     net_amount: -513500,
    #     status: :needs_response
       
    #   )
    #   d.dispute_transactions.create( gross_amount: -512000, fee_total: -1500, payment: create(:payment, 
    #     nonprofit: nonprofit, 
    #     gross_amount: -512000,
    #     fee_total: -1500,
    #     net_amount: -513500))
    #   d
    # end


    let(:nonprofit_balances) { QueryPayments.nonprofit_balances(nonprofit.id)}

    before(:each) do
      entities_today
    end

    describe ".nonprofit_balances" do 
      it 'has a pending balance of 400' do
        expect(nonprofit_balances['pending_gross']).to eq 400
      end

      it 'has an available balance of 53200' do
        expect(nonprofit_balances['available_gross']).to eq 53200
      end
    end
    
    describe '.for_payout' do
      let(:payments) do  
        [
          entities_today[:legacy_dispute_paid].dispute_transactions.first.payment, 
          entities_today[:dispute_paid].dispute_transactions.first.payment,
          entities_today[:charge_paid].payment,
          entities_today[:refund_disbursed].payment,
        ]
      end

      let(:payout) do
        force_create(:payout, 
        gross_amount:payments.sum{|i| i.gross_amount}, 
        fee_total: payments.sum{|i| i.fee_total}, 
        net_amount: payments.sum{|i| i.net_amount}, 
        nonprofit: nonprofit)
      end

      let(:payment_payouts) do
        payments.map{|p| force_create(:payment_payout, payment: p, payout:payout)}
      end

      let(:bank_account) do 
        force_create(:bank_account, name: "bank", nonprofit: nonprofit)
      end

      let(:result) do 
        QueryPayments.for_payout(nonprofit.id, payout.id)
      end
      
      before(:each) do
        bank_account
        payment_payouts
      end
  
      it 'sets the correct headers' do
        expect(result.first).to eq(["date", "gross_total", "fee_total", "net_total", "bank_name", "status"])
      end
  
      it 'sets the correct payout data' do
        expect(result[1].count).to eq(6) # TODO
      end
      
      it 'sets the payment headers', :pending => true do
        expect(result[3]).to eq(["Date", "Gross Amount", "Fee Total", "Net Amount", "Type", "Payment ID", "Last Name", "First Name", "Full Name", "Organization", "Email", "Phone", "Address", "City", "State", "Postal Code", "Country", "Anonymous?", "Designation", "Honorarium/Memorium", "Comment", "Campaign", "Campaign Gift Level", "Event"])
      end
  
      it 'sets the correct payment data', :pending => true do
        expect(result[4].count).to eq 24
      end
    end
  end
end
