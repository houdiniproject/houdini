# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe InsertBankAccount do
  let(:stripe_helper) { StripeMockHelper.default_helper }
  around do |example|
    Timecop.freeze(2020, 5, 4) do
      StripeMockHelper.mock do
        example.run
      end
    end
  end

  let(:nonprofit) { force_create(:nm_justice) }
  let(:user) { force_create(:user, email: "x@example.com") }

  describe ".with_stripe" do
    describe "param validation" do
      it "validates np and user" do
        expect { InsertBankAccount.with_stripe(nil, nil, nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :nonprofit, name: :required},
            {key: :nonprofit, name: :is_a},
            {key: :user, name: :required},
            {key: :user, name: :is_a}])
        end)

        expect { InsertBankAccount.with_stripe(1, 2, nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :nonprofit, name: :is_a},
            {key: :user, name: :is_a}
          ])
        end)
      end

      it "validate stripe_bank_account_token" do
        expect { InsertBankAccount.with_stripe(nonprofit, user, nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{
            key: :stripe_bank_account_token,
            name: :required
          },
            {
              key: :stripe_bank_account_token,
              name: :not_blank
            }])
        end)
      end

      it "validates whether vetted" do
        expect { InsertBankAccount.with_stripe(nonprofit, user, stripe_bank_account_token: "blah") }.to(raise_error do |error|
          expect(error).to be_a ArgumentError
          expect(error.message).to include("vetted")
        end)
      end
    end

    describe "exceptions in main function" do
      before { nonprofit.vetted = true }

      it "StripeAccount.find_or_create fails" do
        expect(StripeAccount).to receive(:find_or_create).and_raise(StandardError.new)

        expect { InsertBankAccount.with_stripe(nonprofit, user, stripe_bank_account_token: "blah") }.to(raise_error do |error|
          expect(error).to be_a StandardError
        end)
      end

      it "Stripe::Account.retrieve fails" do
        expect(StripeAccount).to receive(:find_or_create).and_return("account_id")
        StripeMockHelper.prepare_error(Stripe::StripeError.new("some error happened"), :get_account)

        expect { InsertBankAccount.with_stripe(nonprofit, user, stripe_bank_account_token: "blah") }.to(raise_error do |error|
          expect(error).to be_a Stripe::StripeError
        end)
      end
    end

    describe "works with account retrieval" do
      before {
        nonprofit.vetted = true
        nonprofit.save!
      }

      let(:stripe_acct) { Stripe::Account.create(managed: true, country: "US", display_name: "test_display_name") }
      let(:stripe_bank_account_token) { StripeMockHelper.generate_bank_token(country: "US", routing_number: "110000000", account_number: "000123456789") }

      it "sets failure message when external_account create fails" do
        expect(Stripe::Account).to receive(:retrieve).and_return(stripe_acct)
        StripeMockHelper.prepare_error(Stripe::StripeError.new("hmm"), :create_external_account)
        expect { InsertBankAccount.with_stripe(nonprofit, user, stripe_bank_account_token: stripe_bank_account_token) }.to raise_error { |error|
          expect(error).to be_a ArgumentError
          expect(error.message).to eq "Failed to connect the bank account: #<Stripe::StripeError: hmm>"
        }
      end

      it "works with external account creation" do
        expect(Stripe::Account).to receive(:retrieve).and_return(stripe_acct)

        result = InsertBankAccount.with_stripe(nonprofit, user, stripe_bank_account_token: stripe_bank_account_token)
        expected = {email: user.email,
                    stripe_bank_account_token: stripe_bank_account_token,
                    pending_verification: true,
                    created_at: Time.now,
                    updated_at: Time.now,
                    status: nil, # doesn't seem to be used
                    id: 1,
                    deleted: nil,
                    account_number: nil, # doesn't seem to be used
                    nonprofit_id: nonprofit.id,
                    bank_name: nil}.with_indifferent_access
        expect(result.attributes.with_indifferent_access.except(:confirmation_token, :stripe_bank_account_id, :name)).to eq expected
        expect(result[:confirmation_token]).to_not be_blank
        expect(result[:stripe_bank_account_id]).to_not be_blank
        expect(result[:name]).to_not be_blank
      end
    end

    describe "handles replacing the old accounts" do
      before do
        nonprofit.vetted = true
        nonprofit.save!
        old_bank_account_false
        old_bank_account_nil
        old_bank_account_true
      end

      let(:stripe_acct) { Stripe::Account.create(managed: true, country: "US", display_name: "test_display_name") }
      let(:stripe_bank_account_token) { StripeMockHelper.generate_bank_token(country: "US", routing_number: "110000000", account_number: "000123456789") }

      let(:old_bank_account_nil) { force_create(:bank_account, nonprofit: nonprofit, deleted: nil) }
      let(:old_bank_account_false) { force_create(:bank_account, nonprofit: nonprofit, deleted: false) }
      let(:old_bank_account_true) { force_create(:bank_account, nonprofit: nonprofit, deleted: true) }

      it "works with external account creation" do
        expect(Stripe::Account).to receive(:retrieve).and_return(stripe_acct)

        result = InsertBankAccount.with_stripe(nonprofit, user, stripe_bank_account_token: stripe_bank_account_token)
        expected = {email: user.email,
                    stripe_bank_account_token: stripe_bank_account_token,
                    pending_verification: true,
                    created_at: Time.now,
                    updated_at: Time.now,
                    status: nil, # doesn't seem to be used
                    id: result["id"],
                    deleted: nil,
                    account_number: nil, # doesn't seem to be used
                    nonprofit_id: nonprofit.id,
                    bank_name: nil}.with_indifferent_access
        expect(result.attributes.with_indifferent_access.except(:confirmation_token, :stripe_bank_account_id, :name)).to eq expected
        expect(result[:confirmation_token]).to_not be_blank
        expect(result[:stripe_bank_account_id]).to_not be_blank
        expect(result[:name]).to_not be_blank

        expect(nonprofit.bank_account).to eq result
        expect(BankAccount.where("nonprofit_id = ?", nonprofit.id).count).to eq 4
        expect(BankAccount.where("nonprofit_id = ? and deleted = true", nonprofit.id).count).to eq 3
      end
    end
  end
end
