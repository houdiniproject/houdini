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
end
