# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertTickets do
  include_context :shared_rd_donation_value_context

  let(:switchover_date) { Time.new(2020, 10, 1) }
  before(:each) do
    stub_const("FEE_SWITCHOVER_TIME", switchover_date)
  end
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
        id: data[:payment_id] || 55555,
        kind: data[:kind] || "Ticket",
        net_amount: amount - data[:payment_fee_total],
        nonprofit_id: data[:nonprofit].id,
        refund_total: 0,
        supporter_id: data[:supporter].id,
        towards: data[:event].name,
        created_at: Time.now,
        updated_at: Time.now
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
        id: data[:charge_id] || 55555,
        amount: amount,
        card_id: data[:card].id,
        created_at: Time.now,
        updated_at: Time.now,
        stripe_charge_id: data[:stripe_charge_id],
        fee: data[:payment_fee_total],
        disbursed: nil,
        failure_message: nil,
        payment_id: data[:payment_id] || 55555,
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

    result[:tickets] = data[:tickets].map.with_index { |item, i|
      {
        id: item[:id],
        quantity: item[:quantity],
        ticket_level_id: item[:ticket_level_id],
        ticket_purchase_id: item[:ticket_purchase_id],
        event_id: data[:event].id,
        supporter_id: data[:supporter].id,
        payment_id: data[:payment_id],
        charge_id: data[:charge_id] || nil,
        event_discount_id: data[:event_discount_id],
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: nil,
        bid_id: i + 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil
      }.with_indifferent_access
    }

    result.with_indifferent_access
  end

  def success_expectations
    expect(InsertTickets).to receive(:generated_ticket_entities).and_wrap_original { |m, *args|
      tickets = m.call(*args)
      ticket_ids = tickets.map { |t| t.id }
      expect(InsertActivities).to receive(:for_tickets).with(ticket_ids)
      expect_job_queued.with(JobTypes::TicketMailerReceiptAdminJob, ticket_ids).once
      # TODO the `anything` should be the charge_id but don't have an obvious way of getting that now.
      expect_job_queued.with(JobTypes::TicketMailerFollowupJob, ticket_ids, anything).once
      tickets
    }
  end

  describe ".create" do
    it "does basic validation" do
      expect {
        InsertTickets.create(event_discount_id: "etheht",
          kind: "blah",
          token: "none")
      }.to raise_error { |error|
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
               {key: :event_id, name: :required},
               {key: :amount, name: :is_integer},
               {key: :amount, name: :required}
             ])
           }.and not_change { ObjectEvent.count }

      # test that the quantity ticket_level validation works (it really doesn't very well)
      expect {
        InsertTickets.create(event_discount_id: "etheht",
          kind: "blah",
          token: "none", tickets: 2, offsite_payment: "bhb", amount: 1400)
      }.to raise_error { |error|
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
           }.and not_change { ObjectEvent.count }
    end

    it "validates the ticket hashes" do
      expect {
        InsertTickets.create(nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          event_id: event.id,
          tickets: [{quantity: 1, ticket_level_id: 1}, {}], amount: 1400)
      }.to raise_error { |error|
             expect(error).to be_a ParamValidation::ValidationError
             expect_validation_errors(error.data, [
               {key: :quantity, name: :is_integer},
               {key: :quantity, name: :min},
               {key: :quantity, name: :required},
               {key: :ticket_level_id, name: :is_reference},
               {key: :ticket_level_id, name: :required}
             ])
           }.and not_change { ObjectEvent.count }
    end

    it "validates the offsite_payment hash" do
      expect {
        InsertTickets.create(nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          event_id: event.id,
          tickets: [{quantity: 1, ticket_level_id: 1}],
          offsite_payment: {kind: "not in list"}, amount: 1400)
      }.to raise_error { |error|
             expect(error).to be_a ParamValidation::ValidationError
             expect_validation_errors(error.data, [
               {key: :kind, name: :included_in}
             ])
           }.and not_change { ObjectEvent.count }
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
        find_error_supporter { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: 55555, token: source_token.token, event_id: event.id, amount: 1400) }
      end

      it "nonprofit is invalid" do
        find_error_nonprofit { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: 55555, supporter_id: supporter.id, token: source_token.token, event_id: event.id, amount: 1400) }
      end

      it "event is invalid" do
        find_error_event { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], amount: charge_amount, nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: 5555) }
      end
    end

    describe "errors during relationship comparison if" do
      it "supporter is deleted" do
        validation_supporter_deleted { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, amount: 1400) }
      end

      it "ticket level is deleted" do
        ticket_level.deleted = true
        ticket_level.save!
        expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, amount: 1400) }.to raise_error { |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [{key: :tickets}])
          expect(error.message).to include "deleted"
          expect(error.message).to include "Ticket level #{ticket_level.id}"
        }.and not_change { ObjectEvent.count }
      end

      it "event is deleted" do
        validation_event_deleted { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, amount: 1400) }
      end

      it "supporter doesnt belong to nonprofit" do
        validation_supporter_not_with_nonprofit { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: other_nonprofit_supporter.id, token: source_token.token, event_id: event.id, amount: 1400) }
      end

      it "event doesnt belong to nonprofit" do
        validation_event_not_with_nonprofit { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: other_ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: other_event.id, amount: 1400) }
      end

      it "event discount doesnt belong to event" do
        expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, event_discount_id: other_event_discount.id, amount: 1400) }.to raise_error { |e|
          expect(e).to be_a ParamValidation::ValidationError
          expect_validation_errors(e.data, [{key: :event_discount_id}])
          expect(e.message).to include "Event discount #{other_event_discount.id}"
          expect(e.message).to include "event #{event.id}"
        }.and not_change { ObjectEvent.count }
      end
    end

    it "verify ticket not available raises properly" do
      expected_error = NotEnoughQuantityError.new(TicketLevel, nil, nil, nil)
      expect(QueryTicketLevels).to receive(:verify_tickets_available).and_raise(expected_error)
      expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, amount: 1400) }.to raise_error(expected_error).and not_change { ObjectEvent.count }
    end

    describe "gross_amount  > 0" do
      around(:each) do |example|
        Timecop.freeze(2020, 5, 4) do
          example.run
        end
      end

      before(:each) {
        # for simplicity, we mock this to $20.00 no matter the ticket choices
        expect(QueryTicketLevels).to receive(:gross_amount_from_tickets).at_least(:once).at_most(:twice).and_return(1600)
      }

      describe "and kind == offsite" do
        describe "errors without current_user" do
          let(:result) { InsertTickets.create(:tickets => [{quantity: 1, ticket_level_id: ticket_level.id}], :nonprofit_id => nonprofit.id, :supporter_id => supporter.id, :token => source_token.token, :event_id => event.id, "kind" => "offsite", :amount => 1600) }
          it "to raise error" do
            expect { result }.to raise_error { |e|
              expect(e).to be_a AuthenticationError
            }.and not_change { ObjectEvent.count }
          end
        end

        describe "errors with unauthorized current_user" do
          let(:result) { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, kind: "offsite", current_user: user, amount: 1600) }
          it "raises error" do
            expect(QueryRoles).to receive(:is_authorized_for_nonprofit?).with(user.id, nonprofit.id).and_return(false)
            expect { result }.to raise_error { |e|
              expect(e).to be_a AuthenticationError
            }.and not_change { ObjectEvent.count }
          end
        end

        describe "succeeds" do
          let(:result) {
            expect(QueryRoles).to receive(:is_authorized_for_nonprofit?).with(user.id, nonprofit.id).and_return true
            InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, kind: "offsite", offsite_payment: {kind: "check", check_number: "fake_checknumber"}, current_user: user, amount: 1600)
          }
          it "has normal results" do
            success_expectations
            ticket_purchase = result["tickets"][0].ticket_purchase
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
                ticket_level_id: ticket_level.id,
                ticket_purchase_id: ticket_purchase.id
              }])
            expect(result["payment"].attributes).to eq expected[:payment]
            expect(result["offsite_payment"].attributes).to eq expected[:offsite_payment]
            expect(result["tickets"].map { |i| i.attributes }[0]).to eq expected[:tickets][0]

            expect(result["tickets"].map(&:ticket_purchase)).to contain_exactly TicketPurchase.last
          end

          it "increases object events by 2" do
            expect { result }.to change { ObjectEvent.count }.by(2)
          end

          it "increases offline_transaction_charge.created by 1" do
            expect { result }.to change { ObjectEvent.where(event_type: "offline_transaction_charge.created").count }.by(1)
          end

          it "increases transaction.created by 1" do
            expect { result }.to change { ObjectEvent.where(event_type: "transaction.created").count }.by(1)
          end

          it "increases Transaction by 1" do
            expect { result }.to change { Transaction.count }.by(1)
          end

          it "increases TicketPurchase by 1" do
            expect { result }.to change { TicketPurchase.count }.by(1)
          end

          it "creates a subtransaction payment whose creation date matches the legacy payment's date" do
            legacy_payment = result["payment"]
            subtransaction_payment = legacy_payment.subtransaction_payment

            expect(subtransaction_payment.created).to eq(legacy_payment.date)
          end
        end
      end

      describe "and kind == charge || nil" do
        let(:basic_valid_ticket_input) {
          {tickets: [{quantity: 1, ticket_level_id: ticket_level.id}, {quantity: 2, ticket_level_id: ticket_level2.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, event_id: event.id, amount: 1600}
        }
        let(:include_fake_token) {
          basic_valid_ticket_input.merge({token: fake_uuid})
        }

        let(:include_valid_token) {
          basic_valid_ticket_input.merge({token: source_token.token})
        }

        describe "kind  == charge" do
          it "token is invalid" do
            validation_invalid_token { InsertTickets.create(include_fake_token.merge({kind: "charge"})) }
          end

          it "errors out if token is unauthorized" do
            validation_unauthorized { InsertTickets.create(include_fake_token.merge({kind: "charge"})) }
          end

          it "errors out if token is expired" do
            validation_expired { InsertTickets.create(include_fake_token.merge({kind: "charge"})) }
          end

          it "card doesnt belong to supporter" do
            validation_card_not_with_supporter { InsertTickets.create(include_fake_token.merge({kind: "charge", token: other_source_token.token})) }
          end

          it "nonprofit isnt vetted" do
            find_error_nonprofit do
              nonprofit.update(vetted: false)
              InsertTickets.create(include_fake_token.merge({kind: "charge", token: other_source_token.token}))
            end
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
            validation_card_not_with_supporter { InsertTickets.create(include_fake_token.merge({kind: "charge", token: other_source_token.token})) }
          end
        end

        it "handles charge failed" do
          handle_charge_failed { InsertTickets.create(include_valid_token) }
        end

        it "succeeds" do
          result = success({amount: 1600, fee: 118})
          p = Payment.find(result["payment"]["id"])
          expect(p.misc_payment_info&.fee_covered).to be_nil
        end

        it "succeeds if offsite_donation is there with empty kind" do
          result = success({offsite_donation: {kind: nil}, amount: 1600, fee: 118})
          p = Payment.find(result["payment"]["id"])
          expect(p.misc_payment_info&.fee_covered).to be_nil
        end

        it "succeeds if fee is covered" do
          result = success({fee_covered: true, amount: 1680, fee: 123})
          p = Payment.find(result["payment"]["id"])
          expect(p.misc_payment_info&.fee_covered).to eq true
        end

        def success(other_elements = {})
          nonprofit.stripe_account_id = Stripe::Account.create["id"]
          nonprofit.save!
          c = Stripe::Customer.create
          source = Stripe::Customer.create_source(c.id, {source: StripeMockHelper.generate_card_token})
          card.stripe_card_id = source.id
          card.stripe_customer_id = c.id
          card.save!

          success_expectations

          insert_charge_expectation = {
            kind: "Ticket",
            towards: event.name,
            metadata: {kind: "Ticket", event_id: event.id, nonprofit_id: nonprofit.id},
            statement: "Tickets #{event.name}",
            amount: other_elements[:amount],
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id,
            card_id: card.id,
            fee_covered: other_elements[:fee_covered]
          }

          expect(InsertCharge).to receive(:with_stripe)
            .with(insert_charge_expectation).and_call_original

          stripe_charge_id = nil
          expect(Stripe::Charge).to receive(:create).with({application_fee_amount: other_elements[:fee],
                                                           customer: c.id,
                                                           amount: other_elements[:amount],
                                                           currency: "usd",
                                                           description: "Tickets The event of Wonders",
                                                           statement_descriptor_suffix: "Tickets The event of W",
                                                           metadata: {kind: "Ticket", event_id: event.id, nonprofit_id: nonprofit.id},
                                                           transfer_data: {destination: "test_acct_1"},
                                                           on_behalf_of: "test_acct_1"}, {stripe_version: "2019-09-09"}).and_wrap_original { |m, *args|
            a = m.call(*args)
            stripe_charge_id = a["id"]
            a
          }
          result = InsertTickets.create(include_valid_token.merge(event_discount_id: event_discount.id).merge(fee_covered: other_elements[:fee_covered], amount: other_elements[:amount]))
          tp = result["tickets"][0].ticket_purchase
          expected = generate_expected_tickets(
            {gross_amount: other_elements[:amount],
             payment_fee_total: other_elements[:fee],
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
               ticket_level_id: ticket_level.id,
               ticket_purchase_id: tp.id
             },
               {
                 id: result["tickets"][0]["id"],
                 quantity: 2,
                 ticket_level_id: ticket_level2.id,
                 ticket_purchase_id: tp.id
               }]}.merge(other_elements)
          )

          expect(result["payment"].attributes).to eq expected[:payment]
          expect(result["charge"].attributes).to eq expected[:charge]
          expect(result["tickets"].map { |i| i.attributes }[0]).to eq expected[:tickets][0]

          result
        end
      end

      it "errors when amount passed is less than expected gross amount" do
        expect { InsertTickets.create(tickets: [{quantity: 1, ticket_level_id: ticket_level.id}], nonprofit_id: nonprofit.id, supporter_id: supporter.id, token: source_token.token, event_id: event.id, amount: 399) }.to raise_error { |e|
          expect(e).to be_a ParamValidation::ValidationError
          expect_validation_errors(e.data, [{key: :amount}])
          expect(e.message).to eq "You authorized a payment of $3.99 but the total value of tickets requested was $16."
        }.and not_change { ObjectEvent.count }
      end

      it "errors where kind == free and positive gross_amount" do
        expect { InsertTickets.create(:tickets => [{quantity: 1, ticket_level_id: ticket_level.id}], :nonprofit_id => nonprofit.id, :supporter_id => supporter.id, :token => source_token.token, :event_id => event.id, "kind" => "free", :amount => 1600) }.to raise_error { |e|
          expect(e).to be_a ParamValidation::ValidationError
          expect_validation_errors(e.data, [{key: :kind}])
          expect(e.message).to eq "Ticket costs money but you didn't pay."
        }.and not_change { ObjectEvent.count }
      end
    end

    describe "when a free ticket is being inserted" do
      before do
        ticket_level.update_attributes(amount: 0)
      end

      let(:ticket) do
        InsertTickets.create(
          tickets: [{
            quantity: 1, ticket_level_id: ticket_level.id
          }],
          nonprofit_id: nonprofit.id,
          supporter_id: supporter.id,
          token: source_token.token,
          event_id: event.id,
          kind: "free",
          current_user: user,
          amount: 0
        )["tickets"].first
      end

      it "creates the corresponding activity" do
        expect(Activity.where(attachment_id: ticket.id).last)
          .to have_attributes({
            attachment_type: "Ticket",
            kind: "Ticket",
            nonprofit_id: nonprofit.id,
            json_data: {
              "event_id" => event.id,
              "quantity" => 1,
              "event_name" => "The event of Wonders",
              "gross_amount" => 0
            }
          })
      end

      it "adds one ObjectEvent" do
        expect { ticket }.to change { ObjectEvent.count }.by(1)
      end

      it "adds one transaction.created event" do
        expect { ticket }.to change { ObjectEvent.where(event_type: "transaction.created").count }.by(1)
      end

      it "adds one Transaction" do
        expect { ticket }.to change { Transaction.count }.by(1)
      end
    end
  end

  describe "generate_bid_ids" do
    let(:event) { create(:event) }
    subject { InsertTickets.generate_bid_ids(event.id, ticket_data) }
    let(:ticket_data) { [{quantity: 1, ticket_level_id: 1}] }

    context "when there are no tickets yet" do
      it "the bid_id starts at 1" do
        expect(subject.first["bid_id"]).to eq(1)
      end
    end

    context "when there are some tickets" do
      let!(:tickets) { [force_create(:ticket, event_id: event.id, bid_id: 1), force_create(:ticket, event_id: event.id, bid_id: 2), force_create(:ticket, event_id: event.id, bid_id: 3)] }

      it "follows creates a bid_id with the next available number" do
        expect(subject.first["bid_id"]).to eq(4)
      end

      context "when some ticket in the middle is deleted" do
        before do
          ticket = Ticket.find_by(bid_id: 2)
          ticket.destroy
        end

        it "the next ticket follows the higher bid_id number" do
          expect(subject.first["bid_id"]).to eq(4)
        end
      end

      context "when the last ticket is deleted" do
        before do
          ticket = Ticket.find_by(bid_id: 3)
          ticket.destroy
        end

        it "the next ticket gets created as the with the destroyed bid_id" do
          expect(subject.first["bid_id"]).to eq(3)
        end
      end
    end
  end
end
