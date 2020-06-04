# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertRefunds, pending: true do
  # before(:all) do
  #   stripe_acct = VCR.use_cassette('InsertRefunds/stripe_acct'){Stripe::Account.create(managed: true, country: 'US', email: 'uzr@example.com').id}
  #  @supp = Psql.execute(Qexpr.new.insert('supporters', [{name: 'nnname'}])).first
  #  @payment = Psql.execute(Qexpr.new.insert('payments', [{supporter_id: @supp['id'], gross_amount: 100, fee_total: 33, net_amount: 67, refund_total: 0}]).returning('*')).first
  #  @nonprofit = Psql.execute(Qexpr.new.insert('nonprofits', [{name: 'xxxx', stripe_account_id: stripe_acct}]).returning('*')).first
  #   stripe_token  = VCR.use_cassette('InsertRefunds/stripe_token'){Stripe::Token.create(card: StripeTestHelpers::Card_immediate).id}
  #   stripe_charge = VCR.use_cassette('InsertRefunds/stripe_charge'){Stripe::Charge.create(amount: 10000, currency: 'usd', source: stripe_token, description: 'charge 1', destination: stripe_acct)}
  #  @charge = Qx.insert_into(:charges).values({
  #    amount: 100,
  #    stripe_charge_id: stripe_charge.id,
  #    nonprofit_id: @nonprofit['id'],
  #    payment_id: @payment['id'],
  #    supporter_id: @supp['id']
  #  }).returning('*').timestamps.execute.first
  #  @refund_amount = 100
  #  @fees = CalculateFees.for_single_amount(100)
  # end

  describe '.with_stripe' do
    context 'when invalid' do
      it 'raises an error with an invalid charge' do
        bad_ch = @charge.merge('stripe_charge_id' => 'xxx')
        expect { InsertRefunds.with_stripe(bad_ch, 'amount' => 1) }.to raise_error(ParamValidation::ValidationError)
        raise
      end

      it 'sets a failure message an error with an invalid amount' do
        bad_ch = @charge.merge('amount' => 0)
        expect { InsertRefunds.with_stripe(bad_ch, 'amount' => 0) }.to raise_error(ParamValidation::ValidationError)
        raise
      end

      it 'returns err if refund amount is greater than payment gross minus payment refund total' do
        new_payment = Qx.insert_into(:payments).values(gross_amount: 1000, fee_total: 0, net_amount: 1000, refund_total: 500).ts.returning('*').execute.first
        new_charge = @charge.merge('payment_id' => new_payment['id'])
        expect { InsertRefunds.with_stripe(new_charge, 'amount' => 600) }.to raise_error(RuntimeError)
        raise
      end
    end

    context 'when valid' do
      # before(:each) do
      #   @result = VCR.use_cassette 'InsertRefunds/result' do
      #     InsertRefunds.with_stripe(@charge, {'amount' => 100})
      # end
      #   @new_payment = Psql.execute("SELECT * FROM payments WHERE id=#{@payment['id']}").first
      # end

      it 'sets the stripe refund id' do
        expect(@result['refund']['stripe_refund_id']).to match(/^re_/)
      end

      it 'creates a negative payment for the refund with the gross amount' do
        expect(@result['payment']['gross_amount']).to eq(-@refund_amount)
      end

      it 'creates a negative payment for the refund with the net amount' do
        expect(@result['payment']['net_amount']).to eq(-@refund_amount + @fees)
      end

      it 'updates the payment_id on the refund' do
        expect(@result['refund']['payment_id']).to eq(@result['payment']['id'])
      end

      it 'increments the payment refund total by the gross amount' do
        expect(@new_payment['refund_total']).to eq(@refund_amount)
      end

      it 'sets the payment supporter id' do
        expect(@result['payment']['supporter_id']).to eq(@supp['id'])
      end

      it 'sets the payment fee_total as negative fees of the original payment' do
        expect(@result['payment']['fee_total']).to eq(CalculateFees.for_single_amount(@refund_amount))
      end
    end
  end
end
