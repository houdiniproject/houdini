require 'spec_helper'
require 'construct/construct_billing_subscription'

describe ConstructBillingSubscription, :pending => true  do

	let(:bp) do
		bp = double("BillingPlan", {id: 1, stripe_plan_id: 'kitchen_sink'})
		return bp
	end

	let(:cust_id) do
    tok = VCR.use_cassette 'ConstructBillingSubscription/card_tok' do
      Stripe::Token.create({card: {
        number: '4242424242424242',
        exp_month: 12,
        exp_year: 2025,
        cvc: '123'
      }}).id
    end
		VCR.use_cassette 'ConstructBillingSubscription/cust_id' do
      Stripe::Customer.create(
        description: 'Test spec customer for ConstructBillingSubscription/cust_id',
        source: tok
      ).id
		end
	end

	describe '.with_stripe' do

		let(:np) do
			card = double("Card", stripe_customer_id: cust_id)
			np = double("Nonprofit", id: 1, created_at: Time.current, card: card)
			allow(np).to receive(:currently_in_trial?).and_return(false)
			np
		end

		context 'when valid' do
			let(:bs) do
				VCR.use_cassette 'ConstructBillingSubscription/bs' do
					ConstructBillingSubscription.with_stripe(np, bp)
				end
			end

			it 'sets the billing_plan_id' do
				expect(bs[:billing_plan_id]).to eq bp.id
			end

			it 'sets the stripe subscription id' do
				expect(bs[:stripe_subscription_id]).to match /^sub_/
			end

			it 'sets the status as active' do
				expect(bs[:status]).to eq 'active'
			end
		end

		context 'when invalid' do
			it 'throws an exception with invalid stripe customer id' do
				allow(np).to receive_message_chain(:card, :stripe_customer_id).and_return('xxx')
				expect do
					VCR.use_cassette 'ConstructBillingSubscription/invalid_customer' do
						ConstructBillingSubscription.with_stripe(np, bp)
					end
				end.to raise_exception(Stripe::InvalidRequestError)
			end

			it 'throws an exception with invalid stripe plan id' do
				allow(bp).to receive(:stripe_plan_id).and_return('xxx')
				expect do
					VCR.use_cassette 'ConstructBillingSubscription/invalid_plan' do
						ConstructBillingSubscription.with_stripe(np, bp)
					end
				end.to raise_exception(Stripe::InvalidRequestError)
			end
		end

	end

end

