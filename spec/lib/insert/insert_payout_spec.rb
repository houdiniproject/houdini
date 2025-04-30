# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
        expect { InsertPayout.with_stripe(nil, nil, nil) }.to(raise_error { |error|
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
        })
      end

      it "validates nonprofit" do
        expect { InsertPayout.with_stripe(666, {stripe_account_id: "valid", email: "valid", user_ip: "valid", bank_name: "valid"}, nil) }.to(raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :np_id}])
        })
      end

      it "errors when the nonprofit is deactivated" do
        np = force_create(:nonprofit, name: "np")
        force_create(:nonprofit_deactivation, nonprofit: np, deactivated: true)
        expect { InsertPayout.with_stripe(np.id, {stripe_account_id: "valid", email: "valid", user_ip: "valid", bank_name: "valid"}, nil) }.to(raise_error { |error|
          expect(error).to be_a ArgumentError
          expect(error.message).to eq "Sorry, this account has been deactivated."
        })
      end

      it "errors when the nonprofit cant make a payout" do
        np = force_create(:nonprofit, name: "np", vetted: false)
        expect { InsertPayout.with_stripe(np.id, {stripe_account_id: "valid", email: "valid", user_ip: "valid", bank_name: "valid"}, nil) }.to(raise_error { |error|
          expect(error).to be_a ArgumentError
          expect(error.message).to eq "Sorry, this account can't make payouts right now."
        })
      end
    end

    context "when valid" do
      around(:each) do |example|
        Timecop.freeze(2020, 5, 5) do
          StripeMockHelper.mock do
            example.run
          end
        end
      end

      context "no charges to payout" do
        include_context "payments for a payout" do
          let(:nonprofit) { force_create(:nonprofit, stripe_account_id: Stripe::Account.create["id"], vetted: true) }
          let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
        end

        let!(:ba) do
          ba = InsertBankAccount.with_stripe(nonprofit, user, {stripe_bank_account_token: StripeMockHelper.generate_bank_token, name: bank_name})
          ba.pending_verification = false
          ba.save!
          ba
        end

        let!(:stripe_account) do
          force_create(:stripe_account, stripe_account_id: nonprofit.stripe_account_id, payouts_enabled: true)
        end

        it "handles no charges to payout" do
          # we have a deactivation record but no deactivate set
          force_create(:nonprofit_deactivation, nonprofit: nonprofit)
          expect { InsertPayout.with_stripe(nonprofit.id, {stripe_account_id: "valid", email: "valid", user_ip: "valid", bank_name: "valid"}, nil) }.to(raise_error { |error|
            expect(error).to be_a ArgumentError
            expect(error.message).to eq "No payments are available for disbursal on this account."
          })
        end
      end

      let(:user) { force_create(:user) }

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
          let(:nonprofit) { force_create(:nonprofit, stripe_account_id: Stripe::Account.create["id"], vetted: true) }
          let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
        end
        let!(:ba) do
          ba = InsertBankAccount.with_stripe(nonprofit, user, {stripe_bank_account_token: StripeMockHelper.generate_bank_token, name: bank_name})
          ba.pending_verification = false
          ba.save!
          ba
        end
        let!(:stripe_account) do
          force_create(:stripe_account, stripe_account_id: nonprofit.stripe_account_id, payouts_enabled: true)
        end

        let!(:expected_payments) { available_payments_yesterday }
        let(:expected_totals) { eb_yesterday.stats.except(:pending_gross, :pending_net) }

        it "works without a date provided" do
          stripe_transfer_id = nil
          expect(Stripe::Payout).to receive(:create).with({amount: expected_totals[:net_amount],
                                                             currency: "usd"}, {
                                                               stripe_account: nonprofit.stripe_account_id
                                                             })
            .and_wrap_original { |m, *args|
            args[0]["status"] = "pending"
            i = m.call(*args)
            stripe_transfer_id = i["id"]
            i
          }
          entities_yesterday
          result = InsertPayout.with_stripe(nonprofit.id, {stripe_account_id: nonprofit.stripe_account_id,
                                                    email: user_email,
                                                    user_ip: user_ip,
                                                    bank_name: bank_name})

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: nonprofit.id,
            status: "pending",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: stripe_transfer_id,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now,
            created_at: Time.now
          }.with_indifferent_access
          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq(expected_result.merge(id: resulted_payout.id, houid: resulted_payout.houid))

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: nil}
          expect(resulted_payout).to have_attributes(expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes))
          expect(resulted_payout.houid).to match_houid(:pyout)
          expect(resulted_payout.payments.pluck("payments.id")).to match_array(expected_payments.map { |i| i.id })
        end

        it "fails properly when Stripe payout call fails" do
          # we have a deactivation record but deactivate set to false
          force_create(:nonprofit_deactivation, nonprofit: nonprofit, deactivated: false)
          StripeMockHelper.prepare_error(Stripe::StripeError.new("Payout failed"), :new_payout)

          entities_yesterday
          expected_payments
          result = InsertPayout.with_stripe(nonprofit.id, {stripe_account_id: nonprofit.stripe_account_id,
                                                    email: user_email,
                                                    user_ip: user_ip,
                                                    bank_name: bank_name})

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: nonprofit.id,
            status: "failed",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: nil,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now,
            created_at: Time.now
          }.with_indifferent_access

          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id, houid: resulted_payout.houid)

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: "Payout failed"}
          expect(resulted_payout).to have_attributes(expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes))

          expect(eb_yesterday.available_payments.map { |i| i.id }).to match_array(expected_payments.map { |i| i.id })
          # validate payment payout records

          expect(resulted_payout.payments.count).to eq 0
        end
      end

      context "previous date provided" do
        include_context "payments for a payout" do
          let(:nonprofit) { force_create(:nonprofit, stripe_account_id: Stripe::Account.create["id"], vetted: true) }
        end

        let!(:ba) do
          ba = InsertBankAccount.with_stripe(nonprofit, user, {stripe_bank_account_token: StripeMockHelper.generate_bank_token, name: bank_name})
          ba.pending_verification = false
          ba.save!
          ba
        end
        let!(:stripe_account) do
          force_create(:stripe_account, stripe_account_id: nonprofit.stripe_account_id, payouts_enabled: true)
        end

        before(:each) do
          entities_yesterday
          entities_two_days_ago
        end

        let!(:expected_payments) { available_payments_two_days_ago }
        let(:expected_totals) { eb_two_days_ago.stats.except(:pending_total) }

        it "works with date provided" do
          stripe_transfer_id = nil
          expect(Stripe::Payout).to receive(:create).with({amount: expected_totals[:net_amount],
                                                             currency: "usd"}, {
                                                               stripe_account: nonprofit.stripe_account_id
                                                             })
            .and_wrap_original { |m, *args|
            args[0]["status"] = "pending"
            i = m.call(*args)
            stripe_transfer_id = i["id"]
            i
          }
          result = InsertPayout.with_stripe(nonprofit.id, {stripe_account_id: nonprofit.stripe_account_id,
                                                    email: user_email,
                                                    user_ip: user_ip,
                                                    bank_name: bank_name}, {date: Time.now - 1.day})

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: nonprofit.id,
            status: "pending",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: stripe_transfer_id,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now,
            created_at: Time.now
          }.with_indifferent_access
          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id, houid: resulted_payout.houid)

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: nil}

          expect(resulted_payout).to have_attributes(expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes))
          expect(resulted_payout.houid).to match_houid(:pyout)

          expect(resulted_payout.payments.pluck("payments.id")).to match_array(expected_payments.map { |i| i.id })
        end

        it "fails properly when Stripe payout call fails" do
          StripeMockHelper.prepare_error(Stripe::StripeError.new("Payout failed"), :new_payout)

          result = InsertPayout.with_stripe(nonprofit.id, {stripe_account_id: nonprofit.stripe_account_id,
                                                    email: user_email,
                                                    user_ip: user_ip,
                                                    bank_name: bank_name}, {date: Time.now - 1.day})

          expected_result = {
            net_amount: expected_totals[:net_amount],
            nonprofit_id: nonprofit.id,
            status: "failed",
            fee_total: expected_totals[:fee_total],
            gross_amount: expected_totals[:gross_amount],
            email: user_email,
            count: expected_totals[:count],
            stripe_transfer_id: nil,
            user_ip: user_ip,
            ach_fee: 0,
            bank_name: bank_name,
            updated_at: Time.now,
            created_at: Time.now
          }.with_indifferent_access

          expect(Payout.count).to eq 1
          resulted_payout = Payout.first
          expect(result.with_indifferent_access).to eq expected_result.merge(id: resulted_payout.id, houid: resulted_payout.houid)

          empty_db_attributes = {manual: nil, scheduled: nil, failure_message: "Payout failed"}
          expect(resulted_payout).to have_attributes(expected_result.merge(id: resulted_payout.id).merge(empty_db_attributes))
          expect(resulted_payout.houid).to match_houid(:pyout)
          expect(eb_two_days_ago.available_payments.map { |i| i.id }).to match_array(expected_payments.map { |i| i.id })
          # validate payment payout records

          expect(resulted_payout.payments.count).to eq 0
        end

        it "creates an associated payout.created object event with the correct fields" do
          result = InsertPayout.with_stripe(nonprofit.id, {stripe_account_id: nonprofit.stripe_account_id,
                                                    email: user_email,
                                                    user_ip: user_ip,
                                                    bank_name: bank_name}, {date: Time.now - 1.day})
          resulting_payout = Payout.find(result["id"])

          expect(resulting_payout.object_events.last.event_type).to eq "payout.created"

          expect(
            resulting_payout.object_events.last.object_json.keys
          ).to contain_exactly("id", "data", "type", "object", "created")

          expect(
            resulting_payout.object_events.last.object_json["data"]["object"].keys
          ).to contain_exactly("id", "object", "status", "created", "net_amount")
        end
      end
    end
  end
end
