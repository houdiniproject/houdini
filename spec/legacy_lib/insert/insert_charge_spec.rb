# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "stripe_mock"

describe InsertCharge do
  include_context :shared_donation_charge_context
  let!(:donation) { force_create(:donation, id: 555) }

  describe ".with_stripe" do
    before do
      Houdini.payment_providers.stripe.connect = true
    end

    describe "param validation" do
      it "does basic validation" do
        expect { InsertCharge.with_stripe(nil) }.to(raise_error do |error|
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
        end)
      end

      it "verify the amount minimum works" do
        expect { InsertCharge.with_stripe(amount: -1) }.to(raise_error do |error|
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
        end)
      end

      it "verify that we check for valid nonprofit" do
        expect do
          InsertCharge.with_stripe(amount: 100,
            nonprofit_id: 5555,
            supporter_id: 5555,
            card_id: 5555,
            statement: "our statement")
        end.to(raise_error do |error|
                 expect(error).to be_a ParamValidation::ValidationError
                 expect_validation_errors(error.data,
                   [
                     {key: :nonprofit_id}
                   ])
               end)
      end

      it "verify that we check for valid supporter" do
        expect do
          InsertCharge.with_stripe(amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: 5555,
            card_id: 5555,
            statement: "our statement")
        end.to(raise_error do |error|
                 expect(error).to be_a ParamValidation::ValidationError
                 expect_validation_errors(error.data,
                   [
                     {key: :supporter_id}
                   ])
               end)
      end
      it "verify that we check for valid card" do
        expect do
          InsertCharge.with_stripe(amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: 5555,
            statement: "our statement")
        end.to(raise_error do |error|
                 expect(error).to be_a ParamValidation::ValidationError
                 expect_validation_errors(error.data,
                   [
                     {key: :card_id}
                   ])
               end)
      end

      it "verify that we check that the supporter belongs to the correct nonprofit" do
        expect do
          InsertCharge.with_stripe(amount: 100,
            nonprofit_id: other_nonprofit.id,
            supporter_id: supporter.id,
            card_id: card.id,
            statement: "our statement")
        end.to(raise_error do |error|
                 expect(error).to be_a ParamValidation::ValidationError
                 expect(error.message).to eq "#{supporter.id} does not belong to this nonprofit #{other_nonprofit.id}"
                 expect_validation_errors(error.data,
                   [
                     {key: :supporter_id}
                   ])
               end)
      end

      it "verify that we check that the card belongs to the correct supporter" do
        expect do
          InsertCharge.with_stripe(amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: card_for_other_supporter.id,
            statement: "our statement")
        end.to(raise_error do |error|
                 expect(error).to be_a ParamValidation::ValidationError
                 expect(error.message).to eq "#{card_for_other_supporter.id} does not belong to this supporter #{supporter.id}"
                 expect_validation_errors(error.data,
                   [
                     {key: :card_id}
                   ])
               end)
      end
    end

    describe "handle StripeAccount Find and Create failure" do
      before do
        StripeMockHelper.prepare_error(Stripe::StripeError.new("chaos"), :new_account)
      end

      it "does it fail properly" do
        expect do
          InsertCharge.with_stripe(amount: 100,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: card.id,
            statement: "our statement")
        end.to(raise_error do |error|
                 expect(error).to be_a Stripe::StripeError
               end)

        expect(Charge).to_not be_exists
        expect(Payment).to_not be_exists
      end
    end

    describe "charge when customer belongs to client" do
      before do
        nonprofit.stripe_account_id = Stripe::Account.create["id"]
        nonprofit.save!
        card.stripe_customer_id = "some other id"
        card.save!
        StripeMockHelper.prepare_error(Stripe::StripeError.new("chaos"), :get_customer)
      end

      it "handles card error" do
        expect(Stripe::Charge).to receive(:create).with({application_fee: 33,
                                                          customer: card.stripe_customer_id,
                                                          amount: 100,
                                                          currency: "usd",
                                                          description: "our statement<> blah-no-way",
                                                          statement_descriptor: "our statement blah-n",
                                                          metadata: nil}, {stripe_account: nonprofit.stripe_account_id}).and_wrap_original { |m, *args| m.call(*args) }
        StripeMockHelper.prepare_card_error(:card_declined)

        finished_result = InsertCharge.with_stripe(amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          card_id: card.id,
          statement: "our statement<> blah-no-way")

        common_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: nil, status: "failed", failure_message: "There was an error with your card: The card was declined", created_at: Time.now, updated_at: Time.now, disbursed: nil}

        result_expected = common_expected.merge(card_id: card.id, nonprofit_id: nonprofit.id, donation_id: nil, supporter_id: supporter.id, ticket_id: nil, payment_id: nil, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

        expect(finished_result["charge"].attributes).to eq result_expected
        expect(Charge.first.attributes).to eq result_expected

        expect(Payment).to_not be_exists
      end

      it "handles general Stripe error" do
        expect(Stripe::Charge).to receive(:create).with({application_fee: 33,
                                                          customer: card.stripe_customer_id,
                                                          amount: 100,
                                                          currency: "usd",
                                                          description: "our statement<> blah-no-way",
                                                          statement_descriptor: "our statement blah-n",
                                                          metadata: nil}, {stripe_account: nonprofit.stripe_account_id}).and_wrap_original { |m, *args| m.call(*args) }
        StripeMockHelper.prepare_error(Stripe::StripeError.new("blah"), :new_charge)

        finished_result = InsertCharge.with_stripe(amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          card_id: card.id,
          statement: "our statement<> blah-no-way")

        common_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: nil, status: "failed", failure_message: "We're sorry, but something went wrong. We've been notified about this issue.", created_at: Time.now, updated_at: Time.now, disbursed: nil}

        result_expected = common_expected.merge(card_id: card.id, nonprofit_id: nonprofit.id, donation_id: nil, supporter_id: supporter.id, ticket_id: nil, payment_id: nil, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

        expect(finished_result["charge"].attributes).to eq result_expected
        expect(Charge.first.attributes).to eq result_expected

        expect(Payment).to_not be_exists
      end
      describe "input success" do
        let(:valid_input) do
          {amount: 100,
           nonprofit_id: nonprofit.id,
           supporter_id: supporter.id,
           card_id: card.id,
           donation_id: 555,
           towards: "blah",
           kind: "kind",
           statement: "our statement<> blah-no-way"}
        end
        let(:date) { Time.new(2002, 10, 31) }
        let(:valid_input_with_date) { valid_input.merge(date: date) }

        it "saves the payment and updates the charge" do
          stripe_charge_id = nil
          expect(Stripe::Charge).to receive(:create).with({application_fee: 33,
                                                            customer: card.stripe_customer_id,
                                                            amount: 100,
                                                            currency: "usd",
                                                            description: "our statement<> blah-no-way",
                                                            statement_descriptor: "our statement blah-n",
                                                            metadata: nil}, {stripe_account: nonprofit.stripe_account_id}).and_wrap_original { |m, *args|
                                      a = m.call(*args)
                                      stripe_charge_id = a["id"]
                                      a
                                    }

          finished_result = InsertCharge.with_stripe(valid_input)

          common_charge_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: stripe_charge_id, status: "pending", failure_message: nil, created_at: Time.now, updated_at: Time.now, disbursed: nil}

          result_charge_expected = common_charge_expected.merge(card_id: card.id, nonprofit_id: nonprofit.id, donation_id: 555, supporter_id: supporter.id, ticket_id: nil, payment_id: Payment.first.id, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

          expect(finished_result["charge"].attributes).to eq result_charge_expected
          expect(Charge.first.attributes).to eq result_charge_expected
          expect(Charge.count).to eq 1

          common_payment_expected = {id: Payment.first.id,
                                     gross_amount: 100,
                                     fee_total: -33,
                                     net_amount: 67,
                                     towards: "blah",
                                     kind: "kind",
                                     donation_id: 555,
                                     nonprofit_id: nonprofit.id,
                                     supporter_id: supporter.id,
                                     refund_total: 0,
                                     date: Time.now,
                                     created_at: Time.now,
                                     updated_at: Time.now,
                                     search_vectors: nil}.with_indifferent_access

          expect(finished_result["payment"].attributes).to eq common_payment_expected
          expect(Payment.first.attributes).to eq common_payment_expected
          expect(Payment.count).to eq 1
        end

        it "saves the payment and updates the charge with passed date" do
          stripe_charge_id = nil
          expect(Stripe::Charge).to receive(:create).with({application_fee: 33,
                                                            customer: card.stripe_customer_id,
                                                            amount: 100,
                                                            currency: "usd",
                                                            description: "our statement<> blah-no-way",
                                                            statement_descriptor: "our statement blah-n",
                                                            metadata: nil}, {stripe_account: nonprofit.stripe_account_id}).and_wrap_original { |m, *args|
                                      a = m.call(*args)
                                      stripe_charge_id = a["id"]
                                      a
                                    }

          finished_result = InsertCharge.with_stripe(valid_input_with_date)

          common_charge_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: stripe_charge_id, status: "pending", failure_message: nil, created_at: Time.now, updated_at: Time.now, disbursed: nil}

          result_charge_expected = common_charge_expected.merge(card_id: card.id, nonprofit_id: nonprofit.id, donation_id: 555, supporter_id: supporter.id, ticket_id: nil, payment_id: Payment.first.id, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

          expect(finished_result["charge"].attributes).to eq result_charge_expected
          expect(Charge.first.attributes).to eq result_charge_expected
          expect(Charge.count).to eq 1

          common_payment_expected = {id: Payment.first.id,
                                     gross_amount: 100,
                                     fee_total: -33,
                                     net_amount: 67,
                                     towards: "blah",
                                     kind: "kind",
                                     donation_id: 555,
                                     nonprofit_id: nonprofit.id,
                                     supporter_id: supporter.id,
                                     refund_total: 0,
                                     date: date,
                                     created_at: Time.now,
                                     updated_at: Time.now,
                                     search_vectors: nil}.with_indifferent_access

          expect(finished_result["payment"].attributes).to eq common_payment_expected
          expect(Payment.first.attributes).to eq common_payment_expected
          expect(Payment.count).to eq 1
        end
      end
    end

    describe "charge when customer belongs to us" do
      before do
        nonprofit.stripe_account_id = Stripe::Account.create["id"]
        nonprofit.save!
        card.stripe_customer_id = "some other id"
        cust = Stripe::Customer.create
        card.stripe_customer_id = cust["id"]
        card.save!
        new_cust = Stripe::Customer.create
        card_for_other_supporter.stripe_customer_id = new_cust["id"]
        card_for_other_supporter.save!
        # StripeMockHelper.prepare_error(Stripe::StripeError.new("chaos"), :get_customer)
      end

      def create_expected_charge_args(expected_card)
        [{application_fee: 33,
          customer: expected_card.stripe_customer_id,
          amount: 100,
          currency: "usd",
          description: "our statement<> blah-no-way",
          statement_descriptor: "our statement blah-n",
          metadata: nil,
          destination: nonprofit.stripe_account_id}, {}]
      end

      it "handles card error" do
        expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(card)).and_wrap_original { |m, *args| m.call(*args) }
        StripeMockHelper.prepare_card_error(:card_declined)

        finished_result = InsertCharge.with_stripe(amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          card_id: card.id,
          statement: "our statement<> blah-no-way")

        common_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: nil, status: "failed", failure_message: "There was an error with your card: The card was declined", created_at: Time.now, updated_at: Time.now, disbursed: nil}

        result_expected = common_expected.merge(card_id: card.id, nonprofit_id: nonprofit.id, donation_id: nil, supporter_id: supporter.id, ticket_id: nil, payment_id: nil, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

        expect(finished_result["charge"].attributes).to eq result_expected
        expect(Charge.first.attributes).to eq result_expected

        expect(Payment).to_not be_exists
      end

      it "handles general Stripe error" do
        expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(card)).and_wrap_original { |m, *args| m.call(*args) }
        StripeMockHelper.prepare_error(Stripe::StripeError.new("blah"), :new_charge)

        finished_result = InsertCharge.with_stripe(amount: 100,
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          card_id: card.id,
          statement: "our statement<> blah-no-way")

        common_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: nil, status: "failed", failure_message: "We're sorry, but something went wrong. We've been notified about this issue.", created_at: Time.now, updated_at: Time.now, disbursed: nil}

        result_expected = common_expected.merge(card_id: card.id, nonprofit_id: nonprofit.id, donation_id: nil, supporter_id: supporter.id, ticket_id: nil, payment_id: nil, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

        expect(finished_result["charge"].attributes).to eq result_expected
        expect(Charge.first.attributes).to eq result_expected

        expect(Payment).to_not be_exists
      end
      describe "input success" do
        let(:date) { Time.new(2002, 10, 31) }

        it "saves the payment and updates the charge" do
          saves_the_payment_updates_the_charge(card)
        end

        it "saves the payment and updates the charge, if old rd and using wrong card" do
          saves_the_payment_updates_the_charge(card_for_other_supporter, true)
        end

        it "saves the payment and updates the charge with passed date" do
          saves_the_payment_and_updates_the_charge_with_passed_date(card)
        end

        it "saves the payment and updates the charge with passed date, if old rd and using wrong card" do
          saves_the_payment_and_updates_the_charge_with_passed_date(card, true)
        end

        def insert_charge_input(expected_card, pass_old_donation = nil, pass_date = nil)
          inner = {amount: 100,
                   nonprofit_id: nonprofit.id,
                   supporter_id: supporter.id,
                   card_id: expected_card.id,
                   donation_id: 555,
                   towards: "blah",
                   kind: "kind",
                   statement: "our statement<> blah-no-way"}

          inner = inner.merge(old_donation: true) if pass_old_donation

          inner = inner.merge(date: date) if pass_date

          inner
        end

        def saves_the_payment_updates_the_charge(expected_card, pass_old_donation = nil)
          stripe_charge_id = nil
          expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(expected_card)).and_wrap_original { |m, *args|
                                      a = m.call(*args)
                                      stripe_charge_id = a["id"]
                                      a
                                    }

          finished_result = InsertCharge.with_stripe(insert_charge_input(expected_card, pass_old_donation))

          common_charge_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: stripe_charge_id, status: "pending", failure_message: nil, created_at: Time.now, updated_at: Time.now, disbursed: nil}

          result_charge_expected = common_charge_expected.merge(card_id: expected_card.id, nonprofit_id: nonprofit.id, donation_id: 555, supporter_id: supporter.id, ticket_id: nil, payment_id: Payment.first.id, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

          expect(finished_result["charge"].attributes).to eq result_charge_expected
          expect(Charge.first.attributes).to eq result_charge_expected
          expect(Charge.count).to eq 1

          common_payment_expected = {id: Payment.first.id,
                                     gross_amount: 100,
                                     fee_total: -33,
                                     net_amount: 67,
                                     towards: "blah",
                                     kind: "kind",
                                     donation_id: 555,
                                     nonprofit_id: nonprofit.id,
                                     supporter_id: supporter.id,
                                     refund_total: 0,
                                     date: Time.now,
                                     created_at: Time.now,
                                     updated_at: Time.now,
                                     search_vectors: nil}.with_indifferent_access

          expect(finished_result["payment"].attributes).to eq common_payment_expected
          expect(Payment.first.attributes).to eq common_payment_expected
          expect(Payment.count).to eq 1
        end

        def saves_the_payment_and_updates_the_charge_with_passed_date(expected_card, pass_old_donation = nil)
          stripe_charge_id = nil
          expect(Stripe::Charge).to receive(:create).with(*create_expected_charge_args(expected_card)).and_wrap_original { |m, *args|
                                      a = m.call(*args)
                                      stripe_charge_id = a["id"]
                                      a
                                    }

          finished_result = InsertCharge.with_stripe(insert_charge_input(expected_card, pass_old_donation, true))

          common_charge_expected = {id: Charge.first.id, amount: 100, fee: 33, stripe_charge_id: stripe_charge_id, status: "pending", failure_message: nil, created_at: Time.now, updated_at: Time.now, disbursed: nil}

          result_charge_expected = common_charge_expected.merge(card_id: card.id, nonprofit_id: nonprofit.id, donation_id: 555, supporter_id: supporter.id, ticket_id: nil, payment_id: Payment.first.id, profile_id: nil, direct_debit_detail_id: nil).with_indifferent_access

          expect(finished_result["charge"].attributes).to eq result_charge_expected
          expect(Charge.first.attributes).to eq result_charge_expected
          expect(Charge.count).to eq 1

          common_payment_expected = {id: Payment.first.id,
                                     gross_amount: 100,
                                     fee_total: -33,
                                     net_amount: 67,
                                     towards: "blah",
                                     kind: "kind",
                                     donation_id: 555,
                                     nonprofit_id: nonprofit.id,
                                     supporter_id: supporter.id,
                                     refund_total: 0,
                                     date: date,
                                     created_at: Time.now,
                                     updated_at: Time.now,
                                     search_vectors: nil}.with_indifferent_access

          expect(finished_result["payment"].attributes).to eq common_payment_expected
          expect(Payment.first.attributes).to eq common_payment_expected
          expect(Payment.count).to eq 1
        end
      end
    end
  end
end
