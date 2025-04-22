# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "support/payments_for_a_payout"

describe InsertPayout do
  let(:bank_name) { "CHASE *1234" }
  let(:supporter) { force_create(:supporter) }
  let(:user_email) { "uzr@example.com" }
  let(:user_ip) { "8.8.8.8" }

  describe ".with_stripe" do
    describe "param validation" do
      it "basic param validation" do
        expect { InsertPayout.with_stripe(nil, nil, nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :np_id, name: :required},
            {key: :np_id, name: :is_integer},
            {key: :stripe_account_id, name: :required},
            {key: :stripe_account_id, name: :not_blank},
            {key: :email, name: :required},
            {key: :email, name: :not_blank},
            {key: :user_ip, name: :required},
            {key: :user_ip, name: :not_blank},
            {key: :bank_name, name: :required},
            {key: :bank_name, name: :not_blank}
          ])
        end)
      end

      it "validates nonprofit" do
        expect { InsertPayout.with_stripe(666, {stripe_account_id: "valid", email: "valid", user_ip: "valid", bank_name: "valid"}, nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :np_id}])
        end)
      end
    end

    context "when valid" do
      let(:stripe_helper) { StripeMockHelper.default_helper }

      around do |example|
        Timecop.freeze(2020, 5, 4) do
          StripeMockHelper.mock do
            example.run
          end
        end
      end

      let(:user) { force_create(:user) }

      it "handles no charges to payout" do
        np = force_create(:nm_justice)
        expect { InsertPayout.with_stripe(np.id, {stripe_account_id: "valid", email: "valid", user_ip: "valid", bank_name: "valid"}, nil) }.to(raise_error do |error|
          expect(error).to be_a ArgumentError
          expect(error.message).to eq "No payments are available for disbursal on this account."
        end)
      end

      # Test one basic charge, one charge with a partial refund, and one charge with a full refund

      # refunded payment
      # disputed payment

      # Charge which was after given date
      #
      # Already paid out charge
      # Already paid out dispute
      # already paid out refund

      context "no date provided" do
        include_context "payments for a payout" do
          let(:np) { force_create(:nm_justice, stripe_account_id: Stripe::Account.create["id"], vetted: true) }
          let(:date_for_marking) { Time.now }
          let(:ba) do
            InsertBankAccount.with_stripe(np, user, stripe_bank_account_token: StripeMockHelper.generate_bank_token, name: bank_name)
          end
        end

        before do
          ba
        end

        let(:expected_totals) { {gross_amount: 5500, fee_total: -1200, net_amount: 4300, count: 8} }

        it "works without a date provided" do
          stripe_transfer_id = nil
          expect(Stripe::Transfer).to receive(:create).with({amount: expected_totals[:net_amount],
                                                              currency: "usd",
                                                              recipient: "self"},
            stripe_account: np.stripe_account_id)
            .and_wrap_original { |m, *args|
                                        i = m.call(*args)
                                        stripe_transfer_id = i["id"]
                                        i
                                      }
          all_payments
          result = InsertPayout.with_stripe(np.id, stripe_account_id: np.stripe_account_id,
            email: user_email,
            user_ip: user_ip,
            bank_name: bank_name)

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: np.id,
            status: "pending",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: stripe_transfer_id,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }.with_indifferent_access
          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id)

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: nil}
          expect(resulted_payout.attributes.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes)

          # validate which charges are makred
          @expect_marked[:charges].each do |c|
            c.reload
            expect(c.status).to eq "disbursed"
          end

          # validate which refunds are marked

          @expect_marked[:refunds].each do |r|
            r.reload
            expect(r.disbursed).to eq true
          end

          # validate which disputes are marked
          @expect_marked[:disputes].each do |d|
            d.reload
            expect(d.status).to eq "lost_and_paid"
          end
          # validate payment payout records

          expect(resulted_payout.payments.pluck("payments.id")).to eq @expect_marked[:payouts_records].collect(&:id)
        end

        it "fails properly when Stripe payout call fails" do
          StripeMockHelper.prepare_error(Stripe::StripeError.new("Payout failed"), :new_transfer)

          all_payments
          result = InsertPayout.with_stripe(np.id, stripe_account_id: np.stripe_account_id,
            email: user_email,
            user_ip: user_ip,
            bank_name: bank_name)

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: np.id,
            status: "failed",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: nil,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }.with_indifferent_access

          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id)

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: "Payout failed"}
          expect(resulted_payout.attributes.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes)

          # validate which charges are makred
          @expect_marked[:charges].each do |c|
            c.reload
            expect(c.status).to eq "available"
          end

          # validate which refunds are marked

          @expect_marked[:refunds].each do |r|
            r.reload
            expect(r.disbursed).to be_falsey
          end

          # validate which disputes are marked
          @expect_marked[:disputes].each do |d|
            d.reload
            expect(d.status).to eq "lost"
          end
          # validate payment payout records

          expect(resulted_payout.payments.count).to eq 0
        end
      end

      context "previous date provided" do
        include_context "payments for a payout" do
          let(:np) { force_create(:nm_justice, stripe_account_id: Stripe::Account.create["id"], vetted: true) }
          let(:date_for_marking) { Time.now - 1.day }
          let(:ba) { InsertBankAccount.with_stripe(np, user, stripe_bank_account_token: StripeMockHelper.generate_bank_token, name: bank_name) }
        end
        before do
          ba
        end

        let(:expected_totals) { {gross_amount: 3500, fee_total: -800, net_amount: 2700, count: 7} }

        it "works with date provided" do
          stripe_transfer_id = nil
          expect(Stripe::Transfer).to receive(:create).with({amount: expected_totals[:net_amount],
                                                              currency: "usd",
                                                              recipient: "self"},
            stripe_account: np.stripe_account_id)
            .and_wrap_original { |m, *args|
                                        i = m.call(*args)
                                        stripe_transfer_id = i["id"]
                                        i
                                      }
          all_payments
          result = InsertPayout.with_stripe(np.id, {stripe_account_id: np.stripe_account_id,
                                                     email: user_email,
                                                     user_ip: user_ip,
                                                     bank_name: bank_name}, date: Time.now - 1.day)

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: np.id,
            status: "pending",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: stripe_transfer_id,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }.with_indifferent_access
          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id)

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: nil}
          expect(resulted_payout.attributes.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes)

          # validate which charges are makred
          @expect_marked[:charges].each do |c|
            c.reload
            expect(c.status).to(eq("disbursed"), c.attributes.to_s)
          end

          # validate which refunds are marked
          @expect_marked[:refunds].each do |r|
            r.reload
            expect(r.disbursed).to eq true
          end

          # validate which disputes are marked
          @expect_marked[:disputes].each do |d|
            d.reload
            expect(d.status).to eq "lost_and_paid"
          end
        end

        it "fails properly when Stripe payout call fails" do
          StripeMockHelper.prepare_error(Stripe::StripeError.new("Payout failed"), :new_transfer)

          all_payments
          result = InsertPayout.with_stripe(np.id, {stripe_account_id: np.stripe_account_id,
                                                     email: user_email,
                                                     user_ip: user_ip,
                                                     bank_name: bank_name}, date: Time.now - 1.day)

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: np.id,
            status: "failed",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: nil,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }.with_indifferent_access

          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id)

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: "Payout failed"}
          expect(resulted_payout.attributes.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes)

          # validate which charges are makred
          @expect_marked[:charges].each do |c|
            c.reload
            expect(c.status).to eq "available"
          end

          # validate which refunds are marked
          @expect_marked[:refunds].each do |r|
            r.reload
            expect(r.disbursed).to be_falsey
          end

          # validate which disputes are marked
          @expect_marked[:disputes].each do |d|
            d.reload
            expect(d.status).to eq "lost"
          end
          # validate payment payout records

          expect(resulted_payout.payments.count).to eq 0
        end
      end
    end
  end
end
