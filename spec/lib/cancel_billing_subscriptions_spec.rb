# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'stripe_mock'

describe CancelBillingSubscription do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before(:each) do
    StripeMock.start
    @card_token = StripeMock.generate_card_token(last4: '9191', exp_year: 2011)
    @np = force_create(:nonprofit)
  end
  after { StripeMock.stop }

  describe 'parameter validation' do
    it 'without db' do
      result = CancelBillingSubscription.with_stripe(nil)
      errors = result[:json][:errors]
      expect(errors.length).to eq(2)
      expect(result[:status]).to eq :unprocessable_entity
      expect_validation_errors(errors, [
                                 { key: :nonprofit, name: :required },
                                 { key: :nonprofit, name: :is_a }
                               ])
    end

    context 'with db' do
      before(:each) do
        @np = create(:nonprofit)
      end

      it 'nonprofit valid but no card or billing_subscription' do
        result = CancelBillingSubscription.with_stripe(@np)
        expect_proper_failure(result)
      end
      it 'nonprofit valid but no card' do
        force_create(:billing_subscription, nonprofit: @np)
        result = CancelBillingSubscription.with_stripe(@np)
        expect_proper_failure(result)
      end

      it 'nonprofit valid but no billings subscription' do
        @np.active_card = build(:card)
        result = CancelBillingSubscription.with_stripe(@np)
        expect_proper_failure(result)
      end

      def expect_proper_failure(result)
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result[:json][:error]).to start_with("We don\'t have a subscription for your non-profit. Please contact support.")
      end
    end
  end
  context 'processing the billing subscription' do
    before(:each) do
      bp = create(:billing_plan, amount: 133_333, percentage_fee: 0.33, name: 'fake plan')
      @stripe_customer = Stripe::Customer.create
      @plan = Stripe::Plan.create(id: 'test_str_plan', amount: 0, currency: 'USD', interval: 'year', name: 'test PLan')

      @original_str_subscription = @stripe_customer.subscriptions.create(plan: @plan.id)

      create(:card, holder: @np, stripe_customer_id: @stripe_customer.id)
      @np.billing_subscription = build(:billing_subscription, billing_plan: bp, stripe_subscription_id: @original_str_subscription.id)
      @default_plan = create(:billing_plan, id: Settings.default_bp.id)
    end

    it 'handles failure of stripe properly' do
      StripeMock.prepare_error(Stripe::StripeError.new('some failure'), :retrieve_customer_subscription)
      original_bs = @np.billing_subscription

      result = CancelBillingSubscription.with_stripe(@np)

      expect(result[:status]).to eq :unprocessable_entity
      expect(result[:json][:error]).to start_with('Oops')

      expect(@np.billing_subscription).to eq(original_bs)

      str_customer_reloaded = Stripe::Customer.retrieve(@stripe_customer.id)
      expect(str_customer_reloaded.subscriptions.data).to eq([@original_str_subscription])
    end

    it 'should succeed' do
      result = CancelBillingSubscription.with_stripe(@np)

      expect(result[:status]).to eq :ok
      expect(result[:json]).to eq({})

      expect(@np.billing_subscription.status).to eq 'active'
      expect(@np.billing_subscription.billing_plan).to eq @default_plan
      str_customer_reloaded = Stripe::Customer.retrieve(@stripe_customer.id)
      expect(str_customer_reloaded.subscriptions.data.length).to eq 0
    end
  end
end
