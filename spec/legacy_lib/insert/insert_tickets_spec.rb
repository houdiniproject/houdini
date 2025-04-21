# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe InsertTickets do
  before do
    Houdini.payment_providers.stripe.connect = true
  end

  include_context :shared_rd_donation_value_context

  # @param [Object] data
  def generate_expected_tickets(data = {})
    amount = data[:gross_amount] || 2000

    data[:payment_fee_total] = data[:payment_fee_total] || 0
    result = {
      payment: {
        date: Time.now,
        donation_id: nil,
        fee_total: -1 * data[:payment_fee_total],
        gross_amount: amount,
        id: data[:payment_id] || 55_555,
        kind: data[:kind] || "Ticket",
        net_amount: amount - data[:payment_fee_total],
        nonprofit_id: data[:nonprofit].id,
        refund_total: 0,
        supporter_id: data[:supporter].id,
        towards: data[:event].name,
        created_at: Time.now,
        updated_at: Time.now,
        search_vectors: nil
      }
    }.with_indifferent_access

    if data[:offsite_payment]
      result[:offsite_payment] = {
        id: data[:offsite_payment][:id],
        nonprofit_id: nonprofit.id,
        supporter_id: supporter.id,
        date: Time.current,
        payment_id: data[:payment_id],
        kind: data[:offsite_payment][:kind],
        check_number: data[:offsite_payment][:check_number],
        created_at: Time.now,
        updated_at: Time.now,
        gross_amount: amount,

        donation_id: nil,
        user_id: nil
      }
    end
    unless data[:charge_id].nil?
      result[:activity] = {}

      result[:charge] = {
        id: data[:charge_id] || 55_555,
        amount: amount,
        card_id: data[:card].id,
        created_at: Time.now,
        updated_at: Time.now,
        stripe_charge_id: data[:stripe_charge_id],
        fee: data[:payment_fee_total],
        disbursed: nil,
        failure_message: nil,
        payment_id: data[:payment_id] || 55_555,
        nonprofit_id: data[:nonprofit].id,
        status: "pending",
        profile_id: nil,
        supporter_id: data[:supporter].id,

        donation_id: nil,

        direct_debit_detail_id: nil,

        # deletable
        ticket_id: nil
      }
    end

    result[:tickets] = data[:tickets].map.with_index do |item, i|
      {
        id: item[:id],
        quantity: item[:quantity],
        ticket_level_id: item[:ticket_level_id],
        event_id: data[:event].id,
        supporter_id: data[:supporter].id,
        payment_id: data[:payment_id],
        charge_id: data[:charge_id] || nil,
        event_discount_id: data[:event_discount_id],
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: false,
        bid_id: i + 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil
      }.with_indifferent_access
    end

    result.with_indifferent_access
  end

  def success_expectations
    expect(InsertTickets).to receive(:generated_ticket_entities).and_wrap_original { |m, *args|
      tickets = m.call(*args)
      ticket_ids = tickets.map(&:id)
      expect(InsertActivities).to receive(:for_tickets).with(ticket_ids)
      tickets
    }
  end
  describe ".create" do
    it "does basic validation" do
      expect do
        InsertTickets.create(event_discount_id: "etheht",
          kind: "blah",
          token: "none")
      end.to raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect_validation_errors(error.data, [
                 {key: :tickets, name: :required},
                 {key: :tickets, name: :is_array},
                 {key: :nonprofit_id, name: :required},
                 {key: :nonprofit_id, name: :is_reference},
                 {key: :supporter_id, name: :required},
                 {key: :supporter_id, name: :is_reference},
                 {key: :event_discount_id, name: :is_reference},
                 {key: :kind, name: :included_in},
                 {key: :token, name: :format},
                 {key: :event_id, name: :is_reference},
                 {key: :event_id, name: :required}
               ])
             }

      # test that the quantity ticket_level validation works (it really doesn't very well)
      expect do
        InsertTickets.create(event_discount_id: "etheht",
          kind: "blah",
          token: "none", tickets: 2, offsite_payment: "bhb")
      end.to raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect_validation_errors(error.data, [
                 {key: :tickets, name: :is_array},
                 {key: :nonprofit_id, name: :required},
                 {key: :nonprofit_id, name: :is_reference},
                 {key: :supporter_id, name: :required},
                 {key: :supporter_id, name: :is_reference},
                 {key: :event_id, name: :is_reference},
                 {key: :event_id, name: :required},
                 {key: :event_discount_id, name: :is_reference},
                 {key: :kind, name: :included_in},
                 {key: :token, name: :format},
                 {key: :offsite_payment, name: :is_hash}
               ])
             }
    end

    it "validates the ticket hashes" do
      expect do
        InsertTickets.create(nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          event_id: event.id,
          tickets: [{quantity: 1, ticket_level_id: 1}, {}])
      end.to raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect_validation_errors(error.data, [
                 {key: :quantity, name: :is_integer},
                 {key: :quantity, name: :min},
                 {key: :quantity, name: :required},
                 {key: :ticket_level_id, name: :is_reference},
                 {key: :ticket_level_id, name: :required}
               ])
             }
    end

    it "validates the offsite_payment hash" do
      expect do
        InsertTickets.create(nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          event_id: event.id,
          tickets: [{quantity: 1, ticket_level_id: 1}],
          offsite_payment: {kind: "not in list"})
      end.to raise_error { |error|
               expect(error).to be_a ParamValidation::ValidationError
               expect_validation_errors(error.data, [
                 {key: :kind, name: :included_in}
               ])
             }
    end

    # it 'errors out if token is invalid' do
    #   validation_invalid_token {InsertRecurringDonation.with_stripe(amount: 1, nonprofit_id: 1, supporter_id: 1, token: fake_uuid)}
    # end
    #
    # it 'errors out if token is unauthorized' do
    #   validation_unauthorized {InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid)}
    # end
    #
    # it 'errors out if token is expired' do
    #   validation_expired {InsertRecurringDonation.with_stripe(amount: charge_amount, nonprofit_id: 1, supporter_id: 1, token: fake_uuid)}
    # end
    #
    # it 'card doesnt belong to supporter' do
    #         validation_card_not_with_supporter {InsertTickets.create(tickets:[{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: other_source_token.token, event_id: event.id)}
    #       end

    describe "errors during find if" do
      it "supporter is invalid" do
        find_error_supporter { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: 55_555, token: source_token.token, event_id: event.id) }
      end

      it "nonprofit is invalid" do
        find_error_nonprofit { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: 55_555, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }
      end

      it "event is invalid" do
        find_error_event { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: 5555) }
      end
    end

    describe "errors during relationship comparison if" do
      it "supporter is deleted" do
        validation_supporter_deleted { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }
      end

      it "ticket level is deleted" do
        ticket_level.deleted = true
        ticket_level.save!
        expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }.to raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :tickets}])
          expect(error.message).to include "deleted"
          expect(error.message).to include "Ticket level #{ticket_level.id}"
        }
      end

      it "event is deleted" do
        validation_event_deleted { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }
      end

      it "supporter doesnt belong to nonprofit" do
        validation_supporter_not_with_nonprofit { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: other_nonprofit_supporter.id, token: source_token.token, event_id: event.id) }
      end

      it "event doesnt belong to nonprofit" do
        validation_event_not_with_nonprofit { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: other_ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: other_event.id) }
      end

      it "event discount doesnt belong to event" do
        expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, event_discount_id: other_event_discount.id) }.to raise_error { |e|
          expect(e).to be_a ParamValidation::ValidationError
          expect_validation_errors(e.data, [{key: :event_discount_id}])
          expect(e.message).to include "Event discount #{other_event_discount.id}"
          expect(e.message).to include "event #{event.id}"
        }
      end
    end

    it "verify ticket not available raises properly" do
      expected_error = NotEnoughQuantityError.new(TicketLevel, nil, nil, nil)
      expect(QueryTicketLevels).to receive(:verify_tickets_available).and_raise(expected_error)
      expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id) }.to raise_error(expected_error)
    end

    describe "gross_amount  > 0" do
      before do
        # for simplicity, we mock this to $20.00 no matter the ticket choices
        expect(QueryTicketLevels).to receive(:gross_amount_from_tickets).at_least(:once).at_most(:twice).and_return(1600)
      end

      describe "and kind == offsite" do
        it "errors without current_user" do
          expect { InsertTickets.create(:tickets => [{quantity: 1, ticket_level_id: ticket_level.id}], :nonprofit_id => nonprofit.id, :supporter_id => supporter.id, :token => source_token.token, :event_id => event.id, "kind" => "offsite") }.to raise_error { |e|
            expect(e).to be_a AuthenticationError
          }
        end

        it "errors with unauthorized current_user" do
          expect(QueryRoles).to receive(:is_authorized_for_nonprofit?).with(user.id, nonprofit.id).and_return(false)
          expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, kind: "offsite", current_user: user) }.to raise_error { |e|
            expect(e).to be_a AuthenticationError
          }
        end

        it "succeeds" do
          success_expectations
          expect(QueryRoles).to receive(:is_authorized_for_nonprofit?).with(user.id, nonprofit.id).and_return true
          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything)
          expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything)
          expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_charge_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:offline_transaction_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_created, anything).once.ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_purchase_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args).ordered
          result = InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, kind: "offsite", offsite_payment: {kind: "check", check_number: "fake_checknumber"}, current_user: user)

          expected = generate_expected_tickets(payment_id: result["payment"].id,
            nonprofit: nonprofit,
            supporter: supporter,
            event: event,
            gross_amount: 1600,
            kind: "OffsitePayment",
            offsite_payment: {id: result["offsite_payment"].id, kind: "check", check_number: "fake_checknumber"},
            tickets: [{
              id: result["tickets"][0]["id"],
              quantity: 1,
              ticket_level_id: ticket_level.id
            }])
          expect(result["payment"].attributes).to eq expected[:payment]
          expect(result["offsite_payment"].attributes).to eq expected[:offsite_payment]
          expect(result["tickets"].map(&:attributes)[0]).to eq expected[:tickets][0]
        end
      end

      describe "and kind == charge || nil" do
        let(:basic_valid_ticket_input) do
          {tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, event_id: event.id}
        end
        let(:include_fake_token) do
          basic_valid_ticket_input.merge(token: fake_uuid)
        end

        let(:include_valid_token) do
          basic_valid_ticket_input.merge(token: source_token.token)
        end

        describe "kind  == charge" do
          it "token is invalid" do
            validation_invalid_token { InsertTickets.create(include_fake_token.merge(kind: "charge")) }
          end

          it "errors out if token is unauthorized" do
            validation_unauthorized { InsertTickets.create(include_fake_token.merge(kind: "charge")) }
          end

          it "errors out if token is expired" do
            validation_expired { InsertTickets.create(include_fake_token.merge(kind: "charge")) }
          end

          it "card doesnt belong to supporter" do
            validation_card_not_with_supporter { InsertTickets.create(include_fake_token.merge(kind: "charge", token: other_source_token.token)) }
          end
        end

        describe "kind  == nil" do
          it "token is invalid" do
            validation_invalid_token { InsertTickets.create(include_fake_token) }
          end

          it "errors out if token is unauthorized" do
            validation_unauthorized { InsertTickets.create(include_fake_token) }
          end

          it "errors out if token is expired" do
            validation_expired { InsertTickets.create(include_fake_token) }
          end

          it "card doesnt belong to supporter" do
            validation_card_not_with_supporter { InsertTickets.create(include_fake_token.merge(kind: "charge", token: other_source_token.token)) }
          end
        end

        it "handles charge failed" do
          handle_charge_failed { InsertTickets.create(include_valid_token) }
        end

        it "succeeds" do
          success
        end

        it "succeeds if offsite_donation is there with empty kind" do
          success(offsite_donation: {kind: nil})
        end

        def success(other_elements = {})
          expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything)
          expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything)

          nonprofit.stripe_account_id = Stripe::Account.create["id"]
          nonprofit.save!
          card.stripe_customer_id = "some other id"
          card.save!

          success_expectations
          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, any_args).twice
          expect(Houdini.event_publisher).to receive(:announce).with(:event_discount_created, any_args)

          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_charge_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:payment_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:stripe_transaction_created, any_args).ordered
          ## there are three tickets so have them be announced three times
          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_created, anything).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_created, anything).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_created, anything).ordered

          expect(Houdini.event_publisher).to receive(:announce).with(:ticket_purchase_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:trx_assignment_created, any_args).ordered
          expect(Houdini.event_publisher).to receive(:announce).with(:transaction_created, any_args).ordered
          expect(InsertCharge).to receive(:with_stripe).with(
            kind: "Ticket",
            towards: event.name,
            metadata: {kind: "Ticket", event_id: event.id, nonprofit_id: nonprofit.id},
            statement: "Tickets #{event.name}",
            amount: 1600,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: card.id
          ).and_call_original

          stripe_charge_id = nil
          expect(Stripe::Charge).to receive(:create).with({application_fee: 66,
                                                            customer: card.stripe_customer_id,
                                                            amount: 1600,
                                                            currency: "usd",
                                                            description: "Tickets The event of Wonders",
                                                            statement_descriptor: "Tickets The event of W",
                                                            metadata: {kind: "Ticket", event_id: event.id, nonprofit_id: nonprofit.id}}, {stripe_account: nonprofit.stripe_account_id}).and_wrap_original { |m, *args|
                                      a = m.call(*args)
                                      stripe_charge_id = a["id"]
                                      a
                                    }
          result = InsertTickets.create(include_valid_token.merge(event_discount_id: event_discount.id))
          expected = generate_expected_tickets(
            {gross_amount: 1600,
             payment_fee_total: 66,
             payment_id: result["payment"].id,
             nonprofit: nonprofit,
             supporter: supporter,
             event: event,
             charge_id: result["charge"].id,
             stripe_charge_id: stripe_charge_id,
             event_discount_id: event_discount.id,
             card: card,
             tickets: [{
               id: result["tickets"][0]["id"],
               quantity: 1,
               ticket_level_id: ticket_level.id
             },
               {
                 id: result["tickets"][0]["id"],
                 quantity: 2,
                 ticket_level_id: ticket_level2.id
               }]}.merge(other_elements)
          )

          expect(result["payment"].attributes).to eq expected[:payment]
          expect(result["charge"].attributes).to eq expected[:charge]
          expect(result["tickets"].map(&:attributes)[0]).to eq expected[:tickets][0]
        end
      end

      it "errors where kind == free and positive gross_amount" do
        expect { InsertTickets.create(:tickets => [{quantity: 1, ticket_level_id: ticket_level.id}], :nonprofit_id => nonprofit.id, :supporter_id => supporter.id, :token => source_token.token, :event_id => event.id, "kind" => "free") }.to raise_error { |e|
          expect(e).to be_a ParamValidation::ValidationError
          expect_validation_errors(e.data, [{key: :kind}])
          expect(e.message).to eq "Ticket costs money but you didn't pay."
        }
      end
    end
  end
end
