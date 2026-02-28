# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# rubocop:disable RSpec/MessageSpies, RSpec/NamedSubject, RSpec/MultipleExpectations,RSpec/MultipleMemoizedHelpers, RSpec/ExpectInHook
require "rails_helper"
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil
describe InsertDonation do
  describe ".with_stripe" do
    before do
      Houdini.payment_providers.stripe.connect = true
    end

    include_context :shared_rd_donation_value_context

    describe "param validation" do
      before do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_created, any_args)
        expect(Houdini.event_publisher).to_not receive(:announce).with(:transaction_created, any_args)
      end

      it "does basic validation" do # rubocop:disable RSpec/NoExpectationExample
        validation_basic_validation do
          described_class.with_stripe(designation: 34_124, dedication: 35_141, event_id: "bad", campaign_id: "bad")
        end
      end

      it "errors out if token is invalid" do # rubocop:disable RSpec/NoExpectationExample
        validation_invalid_token do
          described_class.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid)
        end
      end

      it "errors out if token is unauthorized" do # rubocop:disable RSpec/NoExpectationExample
        validation_unauthorized do
          described_class.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid)
        end
      end

      it "errors out if token is expired" do # rubocop:disable RSpec/NoExpectationExample
        validation_expired do
          described_class.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid)
        end
      end

      describe "errors during find if" do
        it "supporter is invalid" do # rubocop:disable RSpec/NoExpectationExample
          find_error_supporter do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: 55_555,
              token: source_token.token)
          end
        end

        it "nonprofit is invalid" do # rubocop:disable RSpec/NoExpectationExample
          find_error_nonprofit do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: 55_555, supporter_id: supporter.id,
              token: source_token.token)
          end
        end

        it "campaign is invalid" do # rubocop:disable RSpec/NoExpectationExample
          find_error_campaign do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token, campaign_id: 5555)
          end
        end

        it "event is invalid" do # rubocop:disable RSpec/NoExpectationExample
          find_error_event do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token, event_id: 5555)
          end
        end

        it "profile is invalid" do # rubocop:disable RSpec/NoExpectationExample
          find_error_profile do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token, profile_id: 5555)
          end
        end
      end

      describe "errors during relationship comparison if" do
        it "supporter is deleted" do # rubocop:disable RSpec/NoExpectationExample
          validation_supporter_deleted do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token)
          end
        end

        it "event is deleted" do # rubocop:disable RSpec/NoExpectationExample
          validation_event_deleted do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token, event_id: event.id)
          end
        end

        it "campaign is deleted" do # rubocop:disable RSpec/NoExpectationExample
          validation_campaign_deleted do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token, campaign_id: campaign.id)
          end
        end

        it "supporter doesnt belong to nonprofit" do # rubocop:disable RSpec/NoExpectationExample
          validation_supporter_not_with_nonprofit do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id,
              supporter_id: other_nonprofit_supporter.id, token: source_token.token)
          end
        end

        it "campaign doesnt belong to nonprofit" do # rubocop:disable RSpec/NoExpectationExample
          validation_campaign_not_with_nonprofit do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token, campaign_id: other_campaign.id)
          end
        end

        it "event doesnt belong to nonprofit" do # rubocop:disable RSpec/NoExpectationExample
          validation_event_not_with_nonprofit do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: source_token.token, event_id: other_event.id)
          end
        end

        it "card doesnt belong to supporter" do # rubocop:disable RSpec/NoExpectationExample
          validation_card_not_with_supporter do
            described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
              token: other_source_token.token)
          end
        end
      end
    end

    it "charge returns failed" do
      expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_created, any_args)
      expect(Houdini.event_publisher).to_not receive(:announce).with(:transaction_created, any_args)
      handle_charge_failed do
        described_class.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
          token: source_token.token)
      end
    end

    describe "success" do
      before do
        before_each_success
        allow(Houdini.event_publisher).to receive(:announce)
        expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
        expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
      end

      it "process event donation" do # rubocop:disable RSpec/NoExpectationExample
        process_event_donation do
          described_class.with_stripe(
            amount: charge_amount,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            token: source_token.token,
            event_id: event.id,
            date: 1.day.from_now.to_s,
            dedication: {
              "type" => "honor",
              "name" => "a name"
            },
            designation: "designation"
          )
        end
      end

      it "process campaign donation" do
        expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, any_args)
        process_campaign_donation do
          described_class.with_stripe(
            amount: charge_amount,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            token: source_token.token,
            campaign_id: campaign.id,
            date: 1.day.from_now.to_s,
            dedication: {"type" => "honor", "name" => "a name"},
            designation: "designation"
          )
        end
      end

      it "processes general donation" do # rubocop:disable RSpec/NoExpectationExample
        process_general_donation do
          described_class.with_stripe(
            amount: charge_amount,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            token: source_token.token,
            profile_id: profile.id,
            date: 1.day.from_now.to_s,
            dedication: {"type" => "honor", "name" => "a name"},
            designation: "designation"
          )
        end
      end
    end

    describe "object event firing" do
      # all the same for all the types of donations; see #603
      let(:created_time) { Time.current }
      let(:common_builder) do
        {"supporter" => supporter.id,
         "nonprofit" => nonprofit.id}
      end

      let(:common_builder_expanded) do
        {
          "supporter" => supporter_builder_expanded,
          "nonprofit" => np_builder_expanded
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
            "subtransaction" => stripe_transaction_id_only,
            "payments" => [stripe_transaction_charge_id_only],
            "transaction_assignments" => [donation_id_only]
          }
        )
      end

      let(:transaction_builder_expanded) do
        transaction_builder.merge(
          common_builder_expanded,
          {
            "subtransaction" => stripe_transaction_builder,
            "payments" => [stripe_transaction_charge_builder],
            "transaction_assignments" => [donation_builder]
          }
        )
      end

      let(:stripe_transaction_id_only) do
        {
          "id" => match_houid("stripetrx"),
          "object" => "stripe_transaction",
          "type" => "subtransaction"
        }
      end

      let(:stripe_transaction_builder) do
        stripe_transaction_id_only.merge(
          common_builder_with_trx_id,
          {
            "initial_amount" => {
              "cents" => charge_amount,
              "currency" => "usd"
            },

            "net_amount" => {
              "cents" => 67,
              "currency" => "usd"
            },

            "payments" => [stripe_transaction_charge_id_only],
            "created" => created_time.to_i
          }
        )
      end

      let(:stripe_transaction_builder_expanded) do
        stripe_transaction_builder.merge(
          common_builder_with_trx,
          common_builder_expanded,
          {
            "payments" => [stripe_transaction_charge_builder]
          }
        )
      end

      let(:stripe_transaction_charge_id_only) do
        {
          "id" => match_houid("stripechrg"),
          "object" => "stripe_transaction_charge",
          "type" => "payment"
        }
      end

      let(:stripe_transaction_charge_builder) do
        stripe_transaction_charge_id_only.merge(
          common_builder_with_trx_id,
          {
            "gross_amount" => {
              "cents" => charge_amount,
              "currency" => "usd"
            },
            "net_amount" => {
              "cents" => 67,
              "currency" => "usd"
            },
            "fee_total" => {
              "cents" => -33,
              "currency" => "usd"
            },
            "subtransaction" => stripe_transaction_id_only,
            "stripe_id" => /test_ch_\d+/,
            "created" => created_time.to_i
          }
        )
      end

      let(:stripe_transaction_charge_builder_expanded) do
        stripe_transaction_charge_builder.merge(
          common_builder_with_trx,
          common_builder_expanded,
          {
            "subtransaction" => stripe_transaction_builder
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
        donation_id_only.merge(common_builder_with_trx_id, {
          "amount" => {
            "cents" => charge_amount,
            "currency" => "usd"
          },
          "designation" => "designation",
          "dedication" => {
            "name" => "a name",
            "type" => "honor"
          }
        })
      end

      let(:donation_builder_expanded) do
        donation_builder.merge(common_builder_with_trx, common_builder_expanded)
      end

      describe "events donations" do
        describe "general with_stripe create" do
          subject do
            process_event_donation do
              described_class.with_stripe(
                {
                  amount: charge_amount,
                  nonprofit_id: nonprofit.id,
                  supporter_id: supporter.id,
                  event_id: event.id,
                  token: source_token.token,
                  dedication: {"name" => "a name", "type" => "honor"},
                  designation: "designation"

                }.with_indifferent_access
              )
            end
          end

          before do
            before_each_success
          end

          it "has fired transaction.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :transaction_created, {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "transaction.created",
                "data" => {
                  "object" => transaction_builder_expanded
                }
              }
            )
            subject
          end

          it "has fired stripe_transaction_charge.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(
              :stripe_transaction_charge_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "stripe_transaction_charge.created",
                "data" => {
                  "object" => stripe_transaction_charge_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

            subject
          end

          it "has fired payment.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :payment_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "payment.created",
                "data" => {
                  "object" => stripe_transaction_charge_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

            subject
          end

          it "has fired stripe_transaction.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :stripe_transaction_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "stripe_transaction.created",
                "data" => {
                  "object" => stripe_transaction_builder_expanded
                }
              }
            )

            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
            subject
          end

          it "has fired donation.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :donation_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "donation.created",
                "data" => {
                  "object" => donation_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
            subject
          end

          it "has fired trx_assignment.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :trx_assignment_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "trx_assignment.created",
                "data" => {
                  "object" => donation_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
            subject
          end
        end
      end

      describe "general donations" do
        subject do
          process_general_donation do
            described_class.with_stripe(
              {
                amount: charge_amount,
                nonprofit_id: nonprofit.id,
                supporter_id: supporter.id,
                token: source_token.token,
                profile_id: profile.id,
                dedication: {"name" => "a name", "type" => "honor"},
                designation: "designation"

              }.with_indifferent_access
            )
          end
        end

        before do
          before_each_success
        end

        it "has fired transaction.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :transaction_created, {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "transaction.created",
              "data" => {
                "object" => transaction_builder_expanded
              }
            }
          )
          subject
        end

        it "has fired stripe_transaction_charge.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(
            :stripe_transaction_charge_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "stripe_transaction_charge.created",
              "data" => {
                "object" => stripe_transaction_charge_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

          subject
        end

        it "has fired payment.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :payment_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "payment.created",
              "data" => {
                "object" => stripe_transaction_charge_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

          subject
        end

        it "has fired stripe_transaction.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :stripe_transaction_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "stripe_transaction.created",
              "data" => {
                "object" => stripe_transaction_builder_expanded
              }
            }
          )

          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          subject
        end

        it "has fired donation.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :donation_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "donation.created",
              "data" => {
                "object" => donation_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          subject
        end

        it "has fired trx_assignment.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :trx_assignment_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "trx_assignment.created",
              "data" => {
                "object" => donation_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          subject
        end
      end

      describe "campaign donations" do
        subject do
          expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, any_args)
          process_campaign_donation do
            described_class.with_stripe(
              {
                amount: charge_amount,
                nonprofit_id: nonprofit.id,
                supporter_id: supporter.id,
                token: source_token.token,
                dedication: {"name" => "a name", "type" => "honor"},
                designation: "designation",
                campaign_id: campaign.id
              }.with_indifferent_access
            )
          end
        end

        before do
          before_each_success
        end

        it "has fired transaction.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :transaction_created, {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "transaction.created",
              "data" => {
                "object" => transaction_builder_expanded
              }
            }
          )
          subject
        end

        it "has fired stripe_transaction_charge.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(
            :stripe_transaction_charge_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "stripe_transaction_charge.created",
              "data" => {
                "object" => stripe_transaction_charge_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

          subject
        end

        it "has fired payment.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :payment_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "payment.created",
              "data" => {
                "object" => stripe_transaction_charge_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

          subject
        end

        it "has fired stripe_transaction.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :stripe_transaction_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "stripe_transaction.created",
              "data" => {
                "object" => stripe_transaction_builder_expanded
              }
            }
          )

          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          subject
        end

        it "has fired donation.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :donation_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "donation.created",
              "data" => {
                "object" => donation_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          subject
        end

        it "has fired trx_assignment.created" do
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          expect(Houdini.event_publisher).to receive(:announce).with(
            :trx_assignment_created,
            {
              "id" => match_houid("objevt"),
              "object" => "object_event",
              "type" => "trx_assignment.created",
              "data" => {
                "object" => donation_builder_expanded
              }
            }
          )
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          subject
        end
      end
    end
  end

  describe "#with_sepa" do
    include_context :shared_rd_donation_value_context

    describe "saves donation" do
      before do
        before_each_sepa_success
      end

      it "process event donation" do # rubocop:disable RSpec/NoExpectationExample
        process_event_donation(sepa: true) do
          described_class.with_sepa(
            amount: charge_amount,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            direct_debit_detail_id: direct_debit_detail.id,
            event_id: event.id,
            date: 1.day.from_now.to_s,
            dedication: {
              "type" => "honor",
              "name" => "a name"
            },
            designation: "designation"
          )
        end
      end

      it "process campaign donation" do
        allow(Houdini.event_publisher).to receive(:announce)
        expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, any_args)
        process_campaign_donation(sepa: true) do
          described_class.with_sepa(
            amount: charge_amount,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            direct_debit_detail_id: direct_debit_detail.id,
            campaign_id: campaign.id,
            date: 1.day.from_now.to_s,
            dedication: {
              "type" => "honor",
              "name" => "a name"
            },
            designation: "designation"
          )
        end
      end

      it "processes general donation" do # rubocop:disable RSpec/NoExpectationExample
        process_general_donation(sepa: true) do
          described_class.with_sepa(
            amount: charge_amount,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            direct_debit_detail_id: direct_debit_detail.id,
            profile_id: profile.id,
            date: 1.day.from_now.to_s,
            dedication: {
              "type" => "honor",
              "name" => "a name"
            },
            designation: "designation"
          )
        end
      end
    end
  end

  describe ".offsite" do
    include_context :shared_rd_donation_value_context
    describe "failures" do
      before do
        expect(Houdini.event_publisher).to_not receive(:announce).with(:payment_created, any_args)
        expect(Houdini.event_publisher).to_not receive(:announce).with(:offline_transaction_charge_created, any_args)
        expect(Houdini.event_publisher).to_not receive(:announce).with(:offline_transaction_created, any_args)
        expect(Houdini.event_publisher).to_not receive(:announce).with(:donation_created, any_args)
        expect(Houdini.event_publisher).to_not receive(:announce).with(:trx_assignment_created, any_args)
        expect(Houdini.event_publisher).to_not receive(:announce).with(:transaction_created, any_args)
      end

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
      before do
        allow(Houdini.event_publisher).to receive(:announce)
      end

      describe "general offsite create" do
        subject do
          described_class.offsite({amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id,
                                   date: created_time.to_s}.with_indifferent_access)
        end

        let(:created_time) { 1.day.from_now }
        let(:common_builder) do
          {"supporter" => supporter.id,
           "nonprofit" => nonprofit.id}
        end

        let(:common_builder_expanded) do
          {
            "supporter" => supporter_builder_expanded,
            "nonprofit" => np_builder_expanded
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
              "payments" => [offline_transaction_charge_id_only],
              "transaction_assignments" => [donation_id_only]
            }
          )
        end

        let(:transaction_builder_expanded) do
          transaction_builder.merge(
            common_builder_expanded,
            {
              "subtransaction" => offline_transaction_builder,
              "payments" => [offline_transaction_charge_builder],
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
          donation_id_only.merge(common_builder_with_trx_id, {
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

        describe "event publishing" do
          it "has fired transaction.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :transaction_created, {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "transaction.created",
                "data" => {
                  "object" => transaction_builder_expanded
                }
              }
            )
            subject
          end

          it "has fired offline_transaction_charge.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(
              :offline_transaction_charge_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "offline_transaction_charge.created",
                "data" => {
                  "object" => offline_transaction_charge_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

            subject
          end

          it "has fired payment.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :payment_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "payment.created",
                "data" => {
                  "object" => offline_transaction_charge_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

            subject
          end

          it "has fired offline_transaction.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :offline_transaction_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "offline_transaction.created",
                "data" => {
                  "object" => offline_transaction_builder_expanded
                }
              }
            )

            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
            subject
          end

          it "has fired donation.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :donation_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "donation.created",
                "data" => {
                  "object" => donation_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
            subject
          end

          it "has fired trx_assignment.created" do
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_charge_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
            expect(Houdini.event_publisher).to receive(:announce).with(
              :trx_assignment_created,
              {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "trx_assignment.created",
                "data" => {
                  "object" => donation_builder_expanded
                }
              }
            )
            expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
            subject
          end
        end
      end
    end
  end
end
# rubocop:enable all
