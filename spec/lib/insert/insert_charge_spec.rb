# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "stripe_mock"

describe InsertCharge do
  include_context :shared_donation_charge_context
  let!(:donation) { force_create(:donation, id: 555) }
  describe ".with_stripe" do
    before(:each) {
      Settings.payment_provider.stripe_connect = true
    }
    describe "param validation" do
      it "does basic validation" do
        expect { InsertCharge.with_stripe(nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data,
            [
              {key: :amount, name: :required},
              {key: :amount, name: :is_integer},
              {key: :amount, name: :min},
              {key: :nonprofit_id, name: :required},
              {key: :nonprofit_id, name: :is_integer},
              {key: :supporter_id, name: :required},
              {key: :supporter_id, name: :is_integer},
              {key: :card_id, name: :required},
              {key: :card_id, name: :is_integer},
              {key: :statement, name: :required},
              {key: :statement, name: :not_blank}
            ])
        })
      end

      it "verify the amount minimum works" do
        expect { InsertCharge.with_stripe({amount: -1}) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data,
            [
              {key: :amount, name: :min},
              {key: :nonprofit_id, name: :required},
              {key: :nonprofit_id, name: :is_integer},
              {key: :supporter_id, name: :required},
              {key: :supporter_id, name: :is_integer},
              {key: :card_id, name: :required},
              {key: :card_id, name: :is_integer},
              {key: :statement, name: :required},
              {key: :statement, name: :not_blank}

            ])
        })
      end

      it "verify that we check for valid nonprofit" do
        expect {
          InsertCharge.with_stripe({amount: 100,
                                           nonprofit_id: 5555,
                                           supporter_id: 5555,
                                           card_id: 5555,
                                           statement: "our statement"})
        }.to(raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect_validation_errors(error.data,
                 [
                   {key: :nonprofit_id}
                 ])
             })
      end

      it "verify that we check for valid supporter" do
        expect {
          InsertCharge.with_stripe({amount: 100,
                                           nonprofit_id: nonprofit.id,
                                           supporter_id: 5555,
                                           card_id: 5555,
                                           statement: "our statement"})
        }.to(raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect_validation_errors(error.data,
                 [
                   {key: :supporter_id}
                 ])
             })
      end
      it "verify that we check for valid card" do
        expect {
          InsertCharge.with_stripe({amount: 100,
                                           nonprofit_id: nonprofit.id,
                                           supporter_id: supporter.id,
                                           card_id: 5555,
                                           statement: "our statement"})
        }.to(raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect_validation_errors(error.data,
                 [
                   {key: :card_id}
                 ])
             })
      end

      it "verify that we check that the supporter belongs to the correct nonprofit" do
        expect {
          InsertCharge.with_stripe({amount: 100,
                                           nonprofit_id: other_nonprofit.id,
                                           supporter_id: supporter.id,
                                           card_id: card.id,
                                           statement: "our statement"})
        }.to(raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect(error.message).to eq "#{supporter.id} does not belong to this nonprofit #{other_nonprofit.id}"
               expect_validation_errors(error.data,
                 [
                   {key: :supporter_id}
                 ])
             })
      end

      it "verify that we check that the card belongs to the correct supporter" do
        expect {
          InsertCharge.with_stripe({amount: 100,
                                           nonprofit_id: nonprofit.id,
                                           supporter_id: supporter.id,
                                           card_id: card_for_other_supporter.id,
                                           statement: "our statement"})
        }.to(raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect(error.message).to eq "#{card_for_other_supporter.id} does not belong to this supporter #{supporter.id}"
               expect_validation_errors(error.data,
                 [
                   {key: :card_id}
                 ])
             })
      end
    end

    describe "handle StripeAccountUtils Find and Create failure" do
      before(:each) {
        StripeMockHelper.prepare_error(Stripe::StripeError.new("chaos"), :new_account)
      }
      it "does it fail properly" do
        expect {
          InsertCharge.with_stripe(amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: card.id,
            statement: "our statement")
        }.to(raise_error { |error|
               expect(error).to be_a Stripe::StripeError
             })

        expect(Charge).to_not be_exists
        expect(Payment).to_not be_exists
      end
    end

    describe "charge when customer belongs to us" do
      RSpec.shared_context :charge_when_customer_belongs_to_us do
        let(:negative_fee_total) { fee_total * -1 }
        let(:net_total) { 100 + negative_fee_total }
        before(:each) {
          nonprofit.stripe_account_id = Stripe::Account.create["id"]
          nonprofit.save!
          card.stripe_customer_id = "some other id"
          cust = Stripe::Customer.create
          card.stripe_customer_id = cust["id"]
          source = Stripe::Customer.create_source(cust.id, {source: generate_card_token(card_brand, card_country)})
          card.stripe_card_id = source.id
          card.save!
          new_cust = Stripe::Customer.create
          new_source = Stripe::Customer.create_source(new_cust.id, {source: generate_card_token(card_brand, card_country)})
          card_for_other_supporter.stripe_customer_id = new_cust["id"]
          card_for_other_supporter.stripe_card_id = new_source.id
          card_for_other_supporter.save!
          # billing_subscription
          # StripeMockHelper.prepare_error(Stripe::StripeError.new("chaos"), :get_customer)
        }

        def create_expected_charge_args(expected_card, fee_total)
          [{
            application_fee_amount: fee_total,
            customer: expected_card.stripe_customer_id,
            amount: 100,
            currency: "usd",
            description: "our statement<> blah-no-way",
            statement_descriptor_suffix: "our statement blah-n",
            metadata: nil,
            transfer_data: {destination: nonprofit.stripe_account_id},
            on_behalf_of: nonprofit.stripe_account_id
          }, {
            stripe_version: "2019-09-09"
          }]
        end

        it "handles card error" do
          expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(card, fee_total)).and_wrap_original { |m, *args| m.call(*args) }
          StripeMockHelper.prepare_card_error(:card_declined)
          finished_result = InsertCharge.with_stripe(amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: card.id,
            statement: "our statement<> blah-no-way")

          common_expected = {id: Charge.first.id, amount: 100, fee: fee_total, stripe_charge_id: nil, status: "failed", failure_message: "There was an error with your card: The card was declined", created_at: Time.now, updated_at: Time.now, disbursed: nil}

          result_expected = common_expected.merge({card_id: card.id, nonprofit_id: nonprofit.id, donation_id: nil, supporter_id: supporter.id, ticket_id: nil, payment_id: nil, profile_id: nil, direct_debit_detail_id: nil}).with_indifferent_access

          expect(finished_result["charge"].attributes).to eq result_expected
          expect(Charge.first.attributes).to eq result_expected

          expect(Payment).to_not be_exists
        end

        it "handles general Stripe error" do
          expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(card, fee_total)).and_wrap_original { |m, *args| m.call(*args) }
          StripeMockHelper.prepare_error(Stripe::StripeError.new("blah"), :new_charge)

          finished_result = InsertCharge.with_stripe(amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: card.id,
            statement: "our statement<> blah-no-way")

          common_expected = {id: Charge.first.id, amount: 100, fee: fee_total, stripe_charge_id: nil, status: "failed", failure_message: "We're sorry, but something went wrong. We've been notified about this issue.", created_at: Time.now, updated_at: Time.now, disbursed: nil}

          result_expected = common_expected.merge({card_id: card.id, nonprofit_id: nonprofit.id, donation_id: nil, supporter_id: supporter.id, ticket_id: nil, payment_id: nil, profile_id: nil, direct_debit_detail_id: nil}).with_indifferent_access

          expect(finished_result["charge"].attributes).to eq result_expected
          expect(Charge.first.attributes).to eq result_expected

          expect(Payment).to_not be_exists
        end
        describe "input success" do
          let(:date) { Time.new(2002, 10, 31) }

          it "saves the payment and updates the charge" do
            saves_the_payment_updates_the_charge(card, fee_total)
          end

          it "saves the payment and updates the charge, if old rd and using wrong card" do
            saves_the_payment_updates_the_charge(card_for_other_supporter, fee_total, true)
          end

          it "saves the payment and updates the charge with passed date" do
            saves_the_payment_and_updates_the_charge_with_passed_date(card, fee_total)
          end

          it "saves the payment and updates the charge with passed date, if old rd and using wrong card" do
            saves_the_payment_and_updates_the_charge_with_passed_date(card, fee_total, true)
          end

          def insert_charge_input(expected_card, fee_total, pass_old_donation = nil, pass_date = nil)
            inner = {amount: 100,
                     nonprofit_id: nonprofit.id,
                     supporter_id: supporter.id,
                     card_id: expected_card.id,
                     donation_id: 555,
                     towards: "blah",
                     kind: "kind",
                     statement: "our statement<> blah-no-way"}

            if pass_old_donation
              inner = inner.merge(old_donation: true)
            end

            if pass_date
              inner = inner.merge(date: date)
            end

            inner
          end

          def saves_the_payment_updates_the_charge(expected_card, fee_total, pass_old_donation = nil)
            stripe_charge_id = nil
            expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(expected_card, fee_total)).and_wrap_original { |m, *args|
              a = m.call(*args)
              stripe_charge_id = a["id"]
              a
            }

            finished_result = InsertCharge.with_stripe(insert_charge_input(expected_card, fee_total, pass_old_donation))

            common_charge_expected = {id: Charge.first.id, amount: 100, fee: fee_total, stripe_charge_id: stripe_charge_id, status: "pending", failure_message: nil, created_at: Time.now, updated_at: Time.now, disbursed: nil}

            result_charge_expected = common_charge_expected.merge({card_id: expected_card.id, nonprofit_id: nonprofit.id, donation_id: 555, supporter_id: supporter.id, ticket_id: nil, payment_id: Payment.first.id, profile_id: nil, direct_debit_detail_id: nil}).with_indifferent_access

            expect(finished_result["charge"].attributes).to eq result_charge_expected
            expect(Charge.first.attributes).to eq result_charge_expected
            expect(Charge.count).to eq 1

            common_payment_expected = {id: Payment.first.id,
                                       gross_amount: 100,
                                       fee_total: negative_fee_total,
                                       net_amount: net_total,
                                       towards: "blah",
                                       kind: "kind",
                                       donation_id: 555,
                                       nonprofit_id: nonprofit.id,
                                       supporter_id: supporter.id,
                                       refund_total: 0,
                                       date: Time.now,
                                       created_at: Time.now,
                                       updated_at: Time.now}.with_indifferent_access

            expect(finished_result["payment"].attributes).to eq common_payment_expected
            expect(Payment.first.attributes).to eq common_payment_expected
            expect(Payment.count).to eq 1
          end

          def saves_the_payment_and_updates_the_charge_with_passed_date(expected_card, fee_total, pass_old_donation = nil)
            stripe_charge_id = nil
            expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(expected_card, fee_total)).and_wrap_original { |m, *args|
              a = m.call(*args)
              stripe_charge_id = a["id"]
              a
            }

            finished_result = InsertCharge.with_stripe(insert_charge_input(expected_card, fee_total, pass_old_donation, true))

            common_charge_expected = {id: Charge.first.id, amount: 100, fee: fee_total, stripe_charge_id: stripe_charge_id, status: "pending", failure_message: nil, created_at: Time.now, updated_at: Time.now, disbursed: nil}

            result_charge_expected = common_charge_expected.merge({card_id: card.id, nonprofit_id: nonprofit.id, donation_id: 555, supporter_id: supporter.id, ticket_id: nil, payment_id: Payment.first.id, profile_id: nil, direct_debit_detail_id: nil}).with_indifferent_access

            expect(finished_result["charge"].attributes).to eq result_charge_expected
            expect(Charge.first.attributes).to eq result_charge_expected
            expect(Charge.count).to eq 1

            common_payment_expected = {id: Payment.first.id,
                                       gross_amount: 100,
                                       fee_total: negative_fee_total,
                                       net_amount: net_total,
                                       towards: "blah",
                                       kind: "kind",
                                       donation_id: 555,
                                       nonprofit_id: nonprofit.id,
                                       supporter_id: supporter.id,
                                       refund_total: 0,
                                       date: date,
                                       created_at: Time.now,
                                       updated_at: Time.now}.with_indifferent_access

            expect(finished_result["payment"].attributes).to eq common_payment_expected
            expect(Payment.first.attributes).to eq common_payment_expected
            expect(Payment.count).to eq 1
          end
        end
      end

      describe "visa local" do
        let(:card_brand) { "Visa" }
        let(:card_country) { "US" }
        let(:fee_total) { 36 }
        include_context :charge_when_customer_belongs_to_us
      end

      describe "visa foreign" do
        let(:card_brand) { "Visa" }
        let(:card_country) { "UK" }
        let(:fee_total) { 37 }
        include_context :charge_when_customer_belongs_to_us
      end

      describe "amex local" do
        let(:card_brand) { "American Express" }
        let(:card_country) { "US" }
        let(:fee_total) { 11 }
        include_context :charge_when_customer_belongs_to_us
      end

      describe "amex foreign" do
        let(:card_brand) { "American Express" }
        let(:card_country) { "UK" }
        let(:fee_total) { 12 }
        include_context :charge_when_customer_belongs_to_us
      end

      describe "discover local" do
        let(:card_brand) { "Discover" }
        let(:card_country) { "US" }
        let(:fee_total) { 40 }
        include_context :charge_when_customer_belongs_to_us
      end

      describe "discover foreign" do
        let(:card_brand) { "Discover" }
        let(:card_country) { "RU" }
        let(:fee_total) { 41 }
        include_context :charge_when_customer_belongs_to_us
      end
    end
  end
end
