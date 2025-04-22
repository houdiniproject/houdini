# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertDonation do
  describe ".with_stripe" do
    before(:each) {
      Settings.payment_provider.stripe_connect = true
    }

    after(:each) {
      Settings.reload!
    }

    include_context :shared_rd_donation_value_context

    describe "param validation" do
      it "does basic validation" do
        validation_basic_validation { InsertDonation.with_stripe({designation: 34124, dedication: 35141, event_id: "bad", campaign_id: "bad"}) }
      end

      it "errors out if token is invalid" do
        validation_invalid_token { InsertDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
      end

      it "errors out if token is unauthorized" do
        validation_unauthorized { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
      end

      it "errors out if token is expired" do
        validation_expired { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
      end

      it "errors out if nonprofit not vetted" do
        find_error_nonprofit do
          nonprofit.vetted = false
          nonprofit.save!
          InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token)
        end
      end

      describe "errors during find if" do
        it "supporter is invalid" do
          find_error_supporter { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: 55555, token: source_token.token) }
        end

        it "nonprofit is invalid" do
          find_error_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: 55555, supporter_id: supporter.id, token: source_token.token) }
        end

        it "campaign is invalid" do
          find_error_campaign { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: 5555) }
        end

        it "event is invalid" do
          find_error_event { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: 5555) }
        end

        it "profile is invalid" do
          find_error_profile { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: 5555) }
        end
      end

      describe "errors during relationship comparison if" do
        it "supporter is deleted" do
          validation_supporter_deleted { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
        end

        it "event is deleted" do
          validation_event_deleted { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }
        end

        it "campaign is deleted" do
          validation_campaign_deleted { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id) }
        end

        it "supporter doesnt belong to nonprofit" do
          validation_supporter_not_with_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: other_nonprofit_supporter.id, token: source_token.token) }
        end

        it "campaign doesnt belong to nonprofit" do
          validation_campaign_not_with_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: other_campaign.id) }
        end

        it "event doesnt belong to nonprofit" do
          validation_event_not_with_nonprofit { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: other_event.id) }
        end

        it "card doesnt belong to supporter" do
          validation_card_not_with_supporter { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: other_source_token.token) }
        end
      end
    end

    it "charge returns failed" do
      handle_charge_failed { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
    end

    describe "success" do
      before(:each) {
        before_each_success
      }
      describe "event donation" do
        let(:result) {
          InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, date: (Time.now + 1.day).to_s, dedication: "dedication", designation: "designation")
        }

        it "process event donation" do
          process_event_donation { result }
        end

        it "increases object event charge by one" do
          expect {
            result
          }.to change {
                 ObjectEvent.where(event_type: "stripe_transaction_charge.created").count
               }.by 1
        end

        it "creates a subtransaction_payment whose creation date matches the legacy payment's date" do
          expect(result["payment"].subtransaction_payment.created).to eq(result["payment"].date)
        end
      end

      describe "campaign donation" do
        let(:result) {
          InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id, date: (Time.now + 1.day).to_s, dedication: "dedication", designation: "designation")
        }

        it "process campaign donation" do
          process_campaign_donation { result }
        end

        it "increases object event charge by one" do
          expect {
            result
          }.to change {
                 ObjectEvent.where(event_type: "stripe_transaction_charge.created").count
               }.by 1
        end

        it "creates a subtransaction_payment whose creation date matches the legacy payment's date" do
          expect(result["payment"].subtransaction_payment.created).to eq(result["payment"].date)
        end
      end
      describe "general donation" do
        let(:result) { InsertDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: profile.id, date: (Time.now + 1.day).to_s, dedication: "dedication", designation: "designation") }
        it "processes general donation" do
          process_general_donation { result }
        end

        it "increases object event charge by one" do
          expect {
            result
          }.to change {
                 ObjectEvent.where(event_type: "stripe_transaction_charge.created").count
               }.by 1
        end
      end
    end
  end

  describe ".offsite" do
    include_context :shared_rd_donation_value_context
    describe "failures" do
      it "fails if amount is missing" do
        expect do
          described_class.offsite(
            {
              nonprofit_id: nonprofit.id,
              supporter_id: supporter.id
            }.with_indifferent_access
          )
        end.to raise_error(ParamValidation::ValidationError)
      end
    end

    describe "success" do
      describe "general offsite create" do
        subject(:trx) do
          result = described_class.offsite(
            {
              amount: charge_amount,
              nonprofit_id: nonprofit.id,
              supporter_id: supporter.id,
              date: created_time.to_s,
              offsite_payment: ActionController::Parameters.new({
                check_number: 1234,
                kind: "check"
              })
            }.with_indifferent_access
          )
          Payment.find(result[:json]["payment"]["id"]).trx
        end

        let(:created_time) { 1.day.from_now }
        let(:common_builder) do
          {
            "supporter" => supporter.id, "nonprofit" => nonprofit.id
          }
        end

        let(:common_builder_expanded) do
          {
            "supporter" => supporter_builder_expanded, "nonprofit" => np_builder_expanded
          }
        end

        let(:common_builder_with_trx_id) do
          common_builder.merge(
            {
              "transaction" => match_houid("trx")
            }
          )
        end

        let(:common_builder_with_trx) do
          common_builder.merge(
            {
              "transaction" => transaction_builder
            }
          )
        end

        let(:np_builder_expanded) do
          {
            "id" => nonprofit.id,
            "name" => nonprofit.name,
            "object" => "nonprofit"
          }
        end

        let(:supporter_builder_expanded) do
          supporter_to_builder_base.merge({"name" => "Fake Supporter Name"})
        end

        let(:transaction_builder) do
          common_builder.merge(
            {
              "id" => match_houid("trx"),
              "object" => "transaction",
              "amount" => {
                "cents" => charge_amount,
                "currency" => "usd"
              },
              "created" => created_time.to_i,
              "subtransaction" => offline_transaction_id_only,
              "subtransaction_payments" => [offline_transaction_charge_id_only],
              "transaction_assignments" => [donation_id_only]
            }
          )
        end

        let(:transaction_builder_expanded) do
          transaction_builder.merge(
            common_builder_expanded,
            {
              "subtransaction" => offline_transaction_builder,
              "subtransaction_payments" => [offline_transaction_charge_builder],
              "transaction_assignments" => [donation_builder]
            }
          )
        end

        let(:offline_transaction_id_only) do
          {
            "id" => match_houid("offlinetrx"),
            "object" => "offline_transaction",
            "type" => "subtransaction"
          }
        end

        let(:offline_transaction_builder) do
          offline_transaction_id_only.merge(
            common_builder_with_trx_id,
            {
              "initial_amount" => {
                "cents" => charge_amount,
                "currency" => "usd"
              },

              "net_amount" => {
                "cents" => charge_amount,
                "currency" => "usd"
              },

              "payments" => [offline_transaction_charge_id_only],
              "created" => created_time.to_i
            }
          )
        end

        let(:offline_transaction_builder_expanded) do
          offline_transaction_builder.merge(
            common_builder_with_trx,
            common_builder_expanded,
            {
              "payments" => [offline_transaction_charge_builder]
            }
          )
        end

        let(:offline_transaction_charge_id_only) do
          {
            "id" => match_houid("offtrxchrg"),
            "object" => "offline_transaction_charge",
            "type" => "payment"
          }
        end

        let(:offline_transaction_charge_builder) do
          offline_transaction_charge_id_only.merge(
            common_builder_with_trx_id,
            {
              "gross_amount" => {
                "cents" => charge_amount,
                "currency" => "usd"
              },
              "net_amount" => {
                "cents" => charge_amount,
                "currency" => "usd"
              },
              "fee_total" => {
                "cents" => 0,
                "currency" => "usd"
              },
              "subtransaction" => offline_transaction_id_only,
              "created" => created_time.to_i
            }
          )
        end

        let(:offline_transaction_charge_builder_expanded) do
          offline_transaction_charge_builder.merge(
            common_builder_with_trx,
            common_builder_expanded,
            {
              "subtransaction" => offline_transaction_builder
            }
          )
        end

        let(:donation_id_only) do
          {
            "id" => match_houid("don"),
            "object" => "donation",
            "type" => "trx_assignment"
          }
        end

        let(:donation_builder) do
          donation_id_only.merge(common_builder_with_trx_id,
            {
              "amount" => {
                "cents" => charge_amount,
                "currency" => "usd"
              },
              "designation" => nil
            })
        end

        let(:donation_builder_expanded) do
          donation_builder.merge(common_builder_with_trx, common_builder_expanded)
        end

        it "creates an offline_transaction_charge.created object event" do
          expect { trx }.to change {
            ObjectEvent.where(event_type: "offline_transaction_charge.created").count
          }.by 1
        end

        it "object event has the correct information" do
          offline_transaction_charge = trx.payments.first.paymentable
          object_event = offline_transaction_charge.object_events.first

          expect(object_event.object_json).to include_json(
            id: object_event.houid,
            type: "offline_transaction_charge.created",
            object: "object_event",
            created: object_event.created.to_i,
            data: {
              object: {
                :id => offline_transaction_charge.houid,
                :type => "payment",
                :legacy_id => offline_transaction_charge.legacy_payment.id,
                :legacy_nonprofit => offline_transaction_charge.nonprofit.id,
                :object => "offline_transaction_charge",
                :created => offline_transaction_charge.created.to_i,
                :nonprofit => nonprofit.houid,
                "supporter" => {
                  "id" => offline_transaction_charge.supporter.houid
                },
                :fee_total => {
                  cents: offline_transaction_charge.fee_total_as_money.cents,
                  currency: "usd"
                },
                :net_amount => {
                  cents: offline_transaction_charge.net_amount_as_money.cents,
                  currency: "usd"
                },
                :gross_amount => {
                  cents: offline_transaction_charge.gross_amount_as_money.cents,
                  currency: "usd"
                },
                :transaction => offline_transaction_charge.subtransaction_payment.trx.houid,
                :check_number => "1234",
                :kind => "check"
              }
            }
          )
        end
      end
    end
  end
end
