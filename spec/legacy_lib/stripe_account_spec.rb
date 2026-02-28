# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "stripe"
require "stripe_mock"

describe StripeAccount do
  let(:stripe_helper) { StripeMockHelper.default_helper }
  around do |example|
    StripeMockHelper.mock do
      example.run
    end
  end

  let(:nonprofit) { force_create(:nm_justice) }

  describe ".find_or_create" do
    describe "param validation" do
      it "basic param validation" do
        expect { StripeAccount.find_or_create(nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :nonprofit_id, name: :required},
            {key: :nonprofit_id, name: :is_integer}])
        end)
      end

      it "validate np" do
        expect { StripeAccount.find_or_create(5555) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :nonprofit_id}])
        end)
      end
    end

    # basically the same as running create
    describe "creates new Stripe Account if none is set exists" do
      let!(:result) { StripeAccount.find_or_create(nonprofit.id) }

      it "returns a Stripe acct id" do
        expect(result).to_not be_blank
      end
      it "sets the Account values on Stripe" do
        saved_account = Stripe::Account.retrieve(result)
        expect(saved_account["managed"]).to eq true
        expect(saved_account["business_name"]).to eq nonprofit.name
        expect(saved_account["email"]).to eq nonprofit.email
        expect(saved_account["business_url"]).to eq nonprofit.website
        expect(saved_account["legal_entity"]["type"]).to eq "company"
        expect(saved_account["legal_entity"]["address"]["city"]).to eq nonprofit.city
        expect(saved_account["legal_entity"]["address"]["state"]).to eq nonprofit.state_code
        expect(saved_account["legal_entity"]["business_name"]).to eq nonprofit.name
        expect(saved_account["product_description"]).to eq "Nonprofit donations"
        expect(saved_account["transfer_schedule"]["interval"]).to eq("manual")
      end

      it "updates the nonprofit itself" do
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end
    end

    describe "get stripe account from database" do
      let(:stripe_acct_id) { "stripe_account_id" }

      let!(:result) do
        nonprofit.stripe_account_id = stripe_acct_id
        nonprofit.slug = "slug"
        nonprofit.save!
        nonprofit.reload
        StripeAccount.find_or_create(nonprofit.id)
      end

      it "returns the expected id" do
        expect(result).to eq stripe_acct_id
      end
    end
  end

  describe ".create" do
    it "param validation" do
      expect { StripeAccount.create(nil) }.to(raise_error do |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :np, name: :required},
          {key: :np, name: :is_a}])
      end)
    end
  end

  describe "testing with valid nonprofit" do
    it "handles Stripe errors properly" do
      StripeMockHelper.prepare_error(Stripe::StripeError.new, :new_account)
      expect { StripeAccount.create(nonprofit) }.to(raise_error do |error|
        expect(error).to be_a Stripe::StripeError
        expect(nonprofit.stripe_account_id).to be_blank
      end)
    end

    describe "saves properly without org email" do
      let!(:result) { StripeAccount.create(nonprofit) }

      it "returns a Stripe acct id" do
        expect(result).to_not be_blank
      end
      it "sets the Account values on Stripe" do
        saved_account = Stripe::Account.retrieve(result)
        expect(saved_account["managed"]).to eq true
        expect(saved_account["business_name"]).to eq nonprofit.name
        expect(saved_account["email"]).to eq nonprofit.email
        expect(saved_account["business_url"]).to eq nonprofit.website
        expect(saved_account["legal_entity"]["type"]).to eq "company"
        expect(saved_account["legal_entity"]["address"]["city"]).to eq nonprofit.city
        expect(saved_account["legal_entity"]["address"]["state"]).to eq nonprofit.state_code
        expect(saved_account["legal_entity"]["business_name"]).to eq nonprofit.name
        expect(saved_account["product_description"]).to eq "Nonprofit donations"
        expect(saved_account["transfer_schedule"]["interval"]).to eq("manual")
      end

      it "updates the nonprofit itself" do
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end
    end

    describe "saves properly without org email" do
      before do
        nonprofit.email = nil
        nonprofit.save!

        role
      end

      let(:admin_role_email) { "email_user@email.email" }
      let(:user) { force_create(:user, email: admin_role_email) }
      let(:role) { force_create(:role, user: user, host: nonprofit, name: :nonprofit_admin) }

      let(:result) { StripeAccount.create(nonprofit) }

      it "returns a Stripe acct id" do
        expect(result).to_not be_blank
      end
      it "sets the Account values on Stripe" do
        saved_account = Stripe::Account.retrieve(result)
        expect(saved_account["managed"]).to eq true
        expect(saved_account["business_name"]).to eq nonprofit.name
        expect(saved_account["email"]).to eq admin_role_email
        expect(saved_account["business_url"]).to eq nonprofit.website
        expect(saved_account["legal_entity"]["type"]).to eq "company"
        expect(saved_account["legal_entity"]["address"]["city"]).to eq nonprofit.city
        expect(saved_account["legal_entity"]["address"]["state"]).to eq nonprofit.state_code
        expect(saved_account["legal_entity"]["business_name"]).to eq nonprofit.name
        expect(saved_account["product_description"]).to eq "Nonprofit donations"
        expect(saved_account["transfer_schedule"]["interval"]).to eq("manual")
      end

      it "updates the nonprofit itself" do
        result
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end
    end
  end
end
