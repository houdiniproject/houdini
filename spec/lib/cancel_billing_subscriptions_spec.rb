# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe CancelBillingSubscription do
  around(:each) do |example|
    StripeMockHelper.mock do
      example.run
    end
  end

  describe "parameter validation" do
    describe "with no parameters" do
      it "has unprocessable status" do
        result = CancelBillingSubscription.with_stripe(nil)

        expect(result[:status]).to eq :unprocessable_entity
      end

      it "has 2 validation errors" do
        # with_stripe_mock do

        result = CancelBillingSubscription.with_stripe(nil)
        errors = result[:json][:errors]
        expect(errors.length).to eq(2)
        expect_validation_errors(errors, [
          {key: :nonprofit, name: :required},
          {key: :nonprofit, name: :is_a}
        ])
      end
    end

    context "with nonprofit" do
      def create_nonprofit_with_billing_subscription
        create(:nonprofit_base, :with_default_billing_subscription)
      end

      def create_nonprofit_without_billing_subscription
        create(:nonprofit_base)
      end

      def create_nonprofit_with_billing_subscription_and_active_card
        create(:nonprofit_base, :with_default_billing_subscription, :with_active_card_on_stripe)
      end

      it "nonprofit valid but no card or billing_subscription" do
        nonprofit = create_nonprofit_without_billing_subscription
        result = CancelBillingSubscription.with_stripe(nonprofit)
        expect_proper_failure(result)
      end

      it "nonprofit valid but no card" do
        nonprofit = create_nonprofit_with_billing_subscription
        result = CancelBillingSubscription.with_stripe(nonprofit)
        expect_proper_failure(result)
      end

      it "nonprofit valid but no billings subscription" do
        nonprofit = create(:nonprofit_base, :with_active_card_on_stripe)
        result = CancelBillingSubscription.with_stripe(nonprofit)
        expect_proper_failure(result)
      end

      def expect_proper_failure(result)
        expect(result[:status]).to eq(:unprocessable_entity)
        expect(result[:json][:error]).to start_with("We don't have a subscription for your non-profit. Please contact support.")
      end
    end
  end
  context "processing the billing subscription" do
    def create_nonprofit
      create(:nonprofit_base, :with_old_billing_plan_on_stripe)
    end

    def create_default_plan
      create(:billing_plan_base, :with_associated_stripe_plan, id: Settings.default_bp.id)
    end

    describe "with a failure" do
      def prepare_stripe_error
        StripeMockHelper.prepare_error(Stripe::StripeError.new("some failure"), :retrieve_customer_subscription)
      end

      it "has a status of :unprocessable entity" do
        np = create_nonprofit
        prepare_stripe_error

        result = CancelBillingSubscription.with_stripe(np)

        expect(result[:status]).to eq :unprocessable_entity
      end

      it "has the correct error message " do
        np = create_nonprofit
        prepare_stripe_error

        result = CancelBillingSubscription.with_stripe(np)

        expect(result[:json][:error]).to start_with("Oops")
      end

      it "hasnt changed the nonprofit's billing_subscription" do
        np = create_nonprofit
        prepare_stripe_error

        expect { CancelBillingSubscription.with_stripe(np) }.to_not change { np.reload.billing_subscription.reload }
      end

      it "hasn't changed the nonprofit Stripe customer subscription" do
        np = create_nonprofit
        prepare_stripe_error
        expect { CancelBillingSubscription.with_stripe(np) }.to_not change { Stripe::Customer.retrieve(np.active_card.stripe_customer_id) }
      end
    end

    describe "successfully" do
      it "has status :ok" do
        np = create_nonprofit
        create_default_plan
        result = CancelBillingSubscription.with_stripe(np)
        expect(result[:status]).to eq :ok
      end

      it "has empty json" do
        np = create_nonprofit
        create_default_plan
        result = CancelBillingSubscription.with_stripe(np)
        expect(result[:json]).to eq({})
      end

      it "has an active billing_subscription" do
        np = create_nonprofit
        create_default_plan
        CancelBillingSubscription.with_stripe(np)

        expect(np.billing_subscription.status).to eq "active"
      end

      it "changed billing_subscription to default" do
        np = create_nonprofit
        default_plan = create_default_plan
        expect { CancelBillingSubscription.with_stripe(np) }.to change { np.billing_subscription.billing_plan }.to default_plan
      end

      it "removed nonprofit's stripe customer subscriptions" do
        np = create_nonprofit
        create_default_plan
        expect { CancelBillingSubscription.with_stripe(np) }.to change { Stripe::Customer.retrieve(np.active_card.stripe_customer_id).subscriptions.data }.to []
      end
    end

    # it 'should succeed' do
    #   prepare
    #   result = CancelBillingSubscription::with_stripe(@np)
    #   expect(result[:status]).to eq :ok
    #   expect(result[:json]).to eq Hash.new

    #   expect
    #   expect(@np.billing_subscription.status).to eq 'active'
    #   expect(@np.billing_subscription.billing_plan).to eq @default_plan
    #   str_customer_reloaded = Stripe::Customer.retrieve(@np.active_card.stripe_customer_id)
    #   expect(str_customer_reloaded.subscriptions.data.length).to eq 0
    # end
  end
end
