# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "stripe"
require "stripe_mock"

describe StripeAccountUtils do
  around(:each) do |example|
    StripeMockHelper.mock do
      example.run
    end
  end

  let(:nonprofit) { force_create(:nonprofit) }
  let(:nonprofit_with_bad_values) { force_create(:nonprofit, state_code: "invalid", zip_code: "not valid", website: "invalid_url", email: "penelope@email.email") }

  describe ".find_or_create" do
    describe "param validation" do
      it "basic param validation" do
        expect { StripeAccountUtils.find_or_create(nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :nonprofit_id, name: :required},
            {key: :nonprofit_id, name: :is_integer}])
        })
      end

      it "validate np" do
        expect { StripeAccountUtils.find_or_create(5555) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :nonprofit_id}])
        })
      end
    end
    # basically the same as running create
    describe "creates new Stripe Account if none is set exists" do
      let!(:result) { StripeAccountUtils.find_or_create(nonprofit.id) }

      it "returns a Stripe acct id" do
        expect(result).to_not be_blank
      end
      it "sets the Account values on Stripe" do
        expect {
          Stripe::Account.retrieve(result)
        }.to_not raise_error
      end

      it "updates the nonprofit itself" do
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end
    end

    describe "get stripe account from database" do
      let(:stripe_acct_id) { "stripe_account_id" }

      let!(:result) {
        nonprofit.stripe_account_id = stripe_acct_id
        nonprofit.slug = "slug"
        nonprofit.save!
        nonprofit.reload
        StripeAccountUtils.find_or_create(nonprofit.id)
      }

      it "returns the expected id" do
        expect(result).to eq stripe_acct_id
      end
    end
  end

  describe ".create" do
    it "param validation" do
      expect { StripeAccountUtils.create(nil) }.to(raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :np, name: :required},
          {key: :np, name: :is_a}])
      })
    end
  end

  describe "testing with valid nonprofit" do
    it "handles Stripe errors properly" do
      StripeMockHelper.prepare_error(Stripe::StripeError.new, :new_account)
      expect { StripeAccountUtils.create(nonprofit) }.to(raise_error { |error|
        expect(error).to be_a Stripe::StripeError
        expect(nonprofit.stripe_account_id).to be_blank
      })
    end

    describe "saves properly without org email" do
      let!(:result) { StripeAccountUtils.create(nonprofit) }

      it "returns a Stripe acct id" do
        expect(result).to_not be_blank
      end
      it "sets the Account values on Stripe" do
        expect {
          Stripe::Account.retrieve(result)
        }.to_not raise_error
      end

      it "updates the nonprofit itself" do
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end
    end

    describe "saves properly without org email" do
      before(:each) {
        nonprofit.email = nil
        nonprofit.save!

        role
      }

      let(:admin_role_email) { "email_user@email.email" }
      let(:user) { force_create(:user, email: admin_role_email) }
      let(:role) { force_create(:role, user: user, host: nonprofit, name: :nonprofit_admin) }

      let(:result) { StripeAccountUtils.create(nonprofit) }

      it "returns a Stripe acct id" do
        expect(result).to_not be_blank
      end
      it "sets the Account values on Stripe" do
        expect {
          Stripe::Account.retrieve(result)
        }.to_not raise_error
      end

      it "updates the nonprofit itself" do
        result
        np = Nonprofit.find(nonprofit.id)
        expect(np.stripe_account_id).to eq result
      end

      it "sets the requested_capabilities to card_payments and transfers" do
        saved_account = Stripe::Account.retrieve(result)
        expect(saved_account.requested_capabilities).to eq ["card_payments", "transfers"]
      end
    end
  end
end
