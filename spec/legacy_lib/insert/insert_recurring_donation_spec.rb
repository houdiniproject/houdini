# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe InsertRecurringDonation do
  describe ".with_stripe" do
    before do
      Houdini.payment_providers.stripe.connect = true
    end

    include_context :shared_rd_donation_value_context

    it "does basic validation" do
      validation_basic_validation { InsertRecurringDonation.with_stripe(designation: 34_124, dedication: 35_141, event_id: "bad", campaign_id: "bad") }
    end

    it "does recurring donation validation" do
      expect do
        InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid,
          recurring_donation: {interval: "not number", start_date: "not_date", time_unit: 4, paydate: "faf"})
      end.to raise_error { |e|
               expect(e).to be_a ParamValidation::ValidationError
               expect_validation_errors(e.data, [
                 {key: :interval, name: :is_integer},
                 {key: :start_date, name: :can_be_date},
                 {key: :time_unit, name: :included_in},
                 {key: :paydate, name: :is_integer}
               ])
             }
    end

    it "does paydate validation min" do
      expect do
        InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid,
          recurring_donation: {paydate: "0"})
      end.to raise_error { |e|
               expect(e).to be_a ParamValidation::ValidationError
               expect_validation_errors(e.data, [
                 {key: :paydate, name: :min}
               ])
             }
    end

    it "does paydate validation max" do
      expect do
        InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid,
          recurring_donation: {paydate: "29"})
      end.to raise_error { |e|
               expect(e).to be_a ParamValidation::ValidationError
               expect_validation_errors(e.data, [
                 {key: :paydate, name: :max}
               ])
             }
    end

    it "errors out if token is invalid" do
      validation_invalid_token { InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
    end

    it "errors out if token is unauthorized" do
      validation_unauthorized { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
    end

    it "errors out if token is expired" do
      validation_expired { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid) }
    end

    describe "errors during find if" do
      it "supporter is invalid" do
        find_error_supporter { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: 55_555, token: source_token.token) }
      end

      it "nonprofit is invalid" do
        find_error_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 55_555, supporter_id: supporter.id, token: source_token.token) }
      end

      it "campaign is invalid" do
        find_error_campaign { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: 5555) }
      end

      it "event is invalid" do
        find_error_event { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: 5555) }
      end

      it "profile is invalid" do
        find_error_profile { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: 5555) }
      end
    end

    describe "errors during relationship comparison if" do
      it "event is deleted" do
        validation_event_deleted { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }
      end

      it "campaign is deleted" do
        validation_campaign_deleted { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id) }
      end

      it "supporter is deleted" do
        validation_supporter_deleted { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
      end

      it "supporter doesnt belong to nonprofit" do
        validation_supporter_not_with_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: other_nonprofit_supporter.id, token: source_token.token) }
      end

      it "campaign doesnt belong to nonprofit" do
        validation_campaign_not_with_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: other_campaign.id) }
      end

      it "event doesnt belong to nonprofit" do
        validation_event_not_with_nonprofit { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: other_event.id) }
      end

      it "card doesnt belong to supporter" do
        validation_card_not_with_supporter { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: other_source_token.token) }
      end
    end

    it "charge returns failed" do
      handle_charge_failed { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token) }
    end

    describe "success" do
      before do
        allow(SecureRandom).to receive(:uuid).and_return(default_edit_token)
        allow(Houdini.event_publisher).to receive(:announce)
      end

      describe "charge happens" do
        before do
          before_each_success
        end

        it "process event donation" do
          process_event_donation(recurring_donation: {paydate: nil, interval: 1, time_unit: "year", start_date: Time.current.beginning_of_day}) { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, date: (Time.now + 1.day).to_s, dedication: {"type" => "honor", "name" => "a name"}, designation: "designation", recurring_donation: {time_unit: "year"}) }
        end

        it "process campaign donation" do
          expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, any_args)
          process_campaign_donation(recurring_donation: {paydate: nil, interval: 2, time_unit: "month", start_date: Time.current.beginning_of_day}) { InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, campaign_id: campaign.id, date: (Time.now + 1.day).to_s, dedication: {"type" => "honor", "name" => "a name"}, designation: "designation", recurring_donation: {interval: 2}) }
        end

        it "processes general donation with no recurring donation hash" do
          process_general_donation(recurring_donation: {paydate: Time.now.day, interval: 1, time_unit: "month", start_date: Time.now.beginning_of_day}) do
            InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: profile.id, date: Time.now.to_s, dedication: {"type" => "honor", "name" => "a name"}, designation: "designation")
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

          let(:recurrence_builder_expanded) do
          end

          describe "general donations" do
            subject do
              process_general_donation(recurring_donation: {paydate: Time.now.day, interval: 1, time_unit: "month", start_date: Time.now.beginning_of_day}) do
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

              expect(Houdini.event_publisher).to receive(:announce).with(:recurrence_created, any_args)
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
              expect(Houdini.event_publisher).to receive(:announce).with(:recurrence_created, any_args)
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
              expect(Houdini.event_publisher).to receive(:announce).with(:recurrence_created, any_args)
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
              expect(Houdini.event_publisher).to receive(:announce).with(:recurrence_created, any_args)
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
              expect(Houdini.event_publisher).to receive(:announce).with(:recurrence_created, any_args)
              subject
            end

            it "has fired recurrence.created" do
              expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
              expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
              expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
              expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
              expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
              expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
              expect(Houdini.event_publisher).to receive(:announce).with(:recurrence_created, {
                "id" => match_houid("objevt"),
                "object" => "object_event",
                "type" => "recurrence.created",
                "data" => {
                  "object" => common_builder_expanded.merge({
                    "object" => "recurrence",
                    "id" => match_houid("recur"),
                    "start_date" => Time.new(2020, 5, 4).utc.to_i,
                    "recurrences" => [
                      {
                        "start" => Time.new(2020, 5, 4).utc.to_i,
                        "interval" => 1,
                        "type" => "monthly"
                      }
                    ],
                    "invoice_template" => {
                      "supporter" => supporter.id,
                      "amount" => {"cents" => charge_amount, "currency" => "usd"},
                      "payment_method" => {"type" => "stripe"},
                      "trx_assignments" => [
                        {
                          "assignment_object" => "donation",
                          "dedication" => {"name" => "a name", "type" => "honor", "note" => nil},
                          "designation" => "designation",
                          "amount" => {"cents" => charge_amount, "currency" => "usd"}
                        }
                      ]
                    }
                  })
                }
              })
              subject
            end
          end

          # describe 'campaign donations' do
          # 	subject do
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, any_args)
          # 		process_campaign_donation do
          # 			described_class.with_stripe(
          # 				{
          # 					amount: charge_amount,
          # 					nonprofit_id: nonprofit.id,
          # 					supporter_id: supporter.id,
          # 					token: source_token.token,
          # 					dedication: { 'name' => 'a name', 'type' => 'honor' },
          # 					designation: 'designation',
          # 					campaign_id: campaign.id
          # 				}.with_indifferent_access
          # 			)
          # 		end
          # 	end

          # 	before do
          # 		before_each_success
          # 	end

          # 	it 'has fired transaction.created' do
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(
          # 			:transaction_created, {
          # 				'id' => match_houid('objevt'),
          # 				'object' => 'object_event',
          # 				'type' => 'transaction.created',
          # 				'data' => {
          # 					'object' => transaction_builder_expanded
          # 				}
          # 			}
          # 		)
          # 		subject
          # 	end

          # 	it 'has fired stripe_transaction_charge.created' do
          # 		expect(Houdini.event_publisher).to receive(:announce).with(
          # 			:stripe_transaction_charge_created,
          # 			{
          # 				'id' => match_houid('objevt'),
          # 				'object' => 'object_event',
          # 				'type' => 'stripe_transaction_charge.created',
          # 				'data' => {
          # 					'object' => stripe_transaction_charge_builder_expanded
          # 				}
          # 			}
          # 		)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

          # 		subject
          # 	end

          # 	it 'has fired payment.created' do
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(
          # 			:payment_created,
          # 			{
          # 				'id' => match_houid('objevt'),
          # 				'object' => 'object_event',
          # 				'type' => 'payment.created',
          # 				'data' => {
          # 					'object' => stripe_transaction_charge_builder_expanded
          # 				}
          # 			}
          # 		)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)

          # 		subject
          # 	end

          # 	it 'has fired stripe_transaction.created' do
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(
          # 			:stripe_transaction_created,
          # 			{
          # 				'id' => match_houid('objevt'),
          # 				'object' => 'object_event',
          # 				'type' => 'stripe_transaction.created',
          # 				'data' => {
          # 					'object' => stripe_transaction_builder_expanded
          # 				}
          # 			}
          # 		)

          # 		expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          # 		subject
          # 	end

          # 	it 'has fired donation.created' do
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(
          # 			:donation_created,
          # 			{
          # 				'id' => match_houid('objevt'),
          # 				'object' => 'object_event',
          # 				'type' => 'donation.created',
          # 				'data' => {
          # 					'object' => donation_builder_expanded
          # 				}
          # 			}
          # 		)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          # 		subject
          # 	end

          # 	it 'has fired trx_assignment.created' do
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:donation_created, any_args)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(
          # 			:trx_assignment_created,
          # 			{
          # 				'id' => match_houid('objevt'),
          # 				'object' => 'object_event',
          # 				'type' => 'trx_assignment.created',
          # 				'data' => {
          # 					'object' => donation_builder_expanded
          # 				}
          # 			}
          # 		)
          # 		expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args)
          # 		subject
          # 	end
          # end
        end
      end

      describe "future charge" do
        before do
          before_each_success(false)
        end

        it "processes general donation" do
          process_general_donation(expect_payment: false, expect_charge: false, recurring_donation: {paydate: (Time.now + 5.days).day, interval: 1, time_unit: "month", start_date: (Time.now + 5.days).beginning_of_day}) do
            InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, profile_id: profile.id, date: (Time.now + 1.day).to_s, dedication: {"type" => "honor", "name" => "a name"}, designation: "designation", recurring_donation: {start_date: (Time.now + 5.days).to_s})
          end
        end
      end
    end
  end

  describe ".convert_donation_to_recurring_donation" do
    describe "wonderful testing Eric" do
      before { Timecop.freeze(2020, 4, 29) }
      after { Timecop.return }

      let(:nonprofit) { force_create(:nm_justice, state_code_slug: "wi", city_slug: "city", slug: "sluggster") }
      let(:profile) { force_create(:profile, user: force_create(:user)) }
      let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
      let(:card) { force_create(:card, holder: supporter) }
      let(:campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }
      let(:event) { force_create(:event, profile: profile, nonprofit: nonprofit) }
      let!(:donation) { force_create(:donation, nonprofit: nonprofit, supporter: supporter, amount: 4000, card: card, campaign: campaign, event: event) }
      let!(:payment) { force_create(:payment, donation: donation, kind: "Donation") }

      it "param validation" do
        expect { InsertRecurringDonation.convert_donation_to_recurring_donation(nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :donation_id, name: :required}, {key: :donation_id, name: :is_integer}])
        end)
      end

      it "rejects invalid donation" do
        expect { InsertRecurringDonation.convert_donation_to_recurring_donation(5555) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :donation_id}])
        end)
      end

      it "accepts proper information" do
        Timecop.freeze(2020, 5, 4) do
          rd = InsertRecurringDonation.convert_donation_to_recurring_donation(donation.id)
          # this needs some serious improvement
          expected_rd = {id: rd.id,
                         donation_id: donation.id,
                         nonprofit_id: nonprofit.id,
                         supporter_id: supporter.id,
                         updated_at: Time.now,
                         created_at: Time.now,
                         active: true,
                         n_failures: 0,
                         interval: 1,
                         time_unit: "month",
                         start_date: donation.created_at.beginning_of_day,
                         paydate: 28,
                         profile_id: nil,
                         cancelled_at: nil,
                         cancelled_by: nil,
                         amount: 4000,
                         anonymous: nil,
                         card_id: nil,
                         campaign_id: nil,
                         failure_message: nil,
                         end_date: nil,
                         email: nil,
                         origin_url: nil}.with_indifferent_access

          expect(rd.attributes.except("edit_token")).to eq(expected_rd)

          expect(rd.edit_token).to_not be_falsey

          expect(rd.donation.recurring).to eq true
          expect(rd.donation.payment.kind).to eq "RecurringDonation"
        end
      end
    end

    describe "test for earlier in the month" do
      before { Timecop.freeze(2020, 4, 5) }
      after { Timecop.return }

      let(:nonprofit) { force_create(:nm_justice, state_code_slug: "wi", city_slug: "city", slug: "sluggster") }
      let(:profile) { force_create(:profile, user: force_create(:user)) }
      let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
      let(:card) { force_create(:card, holder: supporter) }
      let(:campaign) { force_create(:campaign, profile: profile, nonprofit: nonprofit) }
      let(:event) { force_create(:event, profile: profile, nonprofit: nonprofit) }

      let!(:donation) { force_create(:donation, nonprofit: nonprofit, supporter: supporter, amount: 4000, card: card, campaign: campaign, event: event) }
      let!(:payment) { force_create(:payment, donation: donation, kind: "Donation") }

      it "works when the date is earlier in the month" do
        Timecop.freeze(2020, 4, 29) do
          rd = InsertRecurringDonation.convert_donation_to_recurring_donation(donation.id)
          # this needs some serious improvement

          expected_rd = {id: rd.id,
                         donation_id: donation.id,
                         nonprofit_id: nonprofit.id,
                         supporter_id: supporter.id,
                         updated_at: Time.now,
                         created_at: Time.now,
                         active: true,
                         n_failures: 0,
                         interval: 1,
                         time_unit: "month",
                         start_date: donation.created_at.beginning_of_day,
                         paydate: 5,
                         profile_id: nil,
                         cancelled_at: nil,
                         cancelled_by: nil,
                         amount: 4000,
                         anonymous: nil,
                         card_id: nil,
                         campaign_id: nil,
                         failure_message: nil,
                         end_date: nil,
                         email: nil,
                         origin_url: nil}.with_indifferent_access
          expect(rd.attributes.except("edit_token")).to eq(expected_rd)

          expect(rd.donation.recurring).to eq true
          expect(rd.donation.payment.kind).to eq "RecurringDonation"

          expect(rd.edit_token).to_not be_falsey
        end
      end
    end
  end
end
