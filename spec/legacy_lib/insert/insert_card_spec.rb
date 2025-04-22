# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
describe InsertCard do
  describe ".with_stripe" do
    let(:stripe_helper) { StripeMockHelper.default_helper }

    let(:stripe_card_token) { StripeMockHelper.generate_card_token(last4: "9191", exp_year: 2011) }
    let(:default_card_attribs) do
      {
        created_at: Time.now,
        updated_at: Time.now,
        profile_id: nil,
        status: nil,
        inactive: nil,
        deleted: nil,
        expiration_month: nil,
        expiration_year: nil,
        email: nil,
        supporter_id: nil
      }
    end

    let(:nonprofit) { force_create(:nm_justice) }
    let(:user) do
      user = force_create(:user)
      force_create(:role, name: :nonprofit_admin, host: nonprofit, user: user)
      user
    end

    around do |example|
      Timecop.freeze(2025, 5, 4) do
        StripeMockHelper.mock do
          example.run
        end
      end
    end

    it "params are invalid" do
      expect { InsertCard.with_stripe({}) }.to raise_error(ParamValidation::ValidationError) do |error|
        expect_validation_errors(error.data, [{key: "holder_id", name: :required},
          {key: "holder_type", name: "included_in"},
          {key: "holder_type", name: "required"},
          {key: "stripe_card_id", name: "required"},
          {key: "stripe_card_id", name: "not_blank"},
          {key: "stripe_card_token", name: "required"},
          {key: "stripe_card_token", name: "not_blank"},
          {key: "name", name: "required"},
          {key: "name", name: "not_blank"}])
      end
      # expect(ret[:status]).to eq(:unprocessable_entity)
      # expect(ret[:json][:error]).to start_with('Validation error')
      # expect(ret[:json][:errors].length).to be(9)

      # expect_validation_errors(ret[:json][:errors], [{ key: 'holder_id', name: :required },
      #                                                { key: 'holder_type', name: 'included_in' },
      #                                                { key: 'holder_type', name: 'required' },
      #                                                { key: 'stripe_card_id', name: 'required' },
      #                                                { key: 'stripe_card_id', name: 'not_blank' },
      #                                                { key: 'stripe_card_token', name: 'required' },
      #                                                { key: 'stripe_card_token', name: 'not_blank' },
      #                                                { key: 'name', name: 'required' },
      #                                                { key: 'name', name: 'not_blank' }])
    end

    describe "for supporter" do
      let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
      let(:event) do
        force_create(:event, nonprofit: nonprofit, end_datetime: Time.now.since(1.day))
      end
      let(:user_not_from_nonprofit) { force_create(:user) }

      def verify_cust_added_supporter(stripe_customer_id, holder_id)
        verify_cust_added(stripe_customer_id, holder_id, "Supporter")
      end

      def verify_supporter_source_token(source_token, card)
        verify_source_token(source_token, card, 1, Time.now.since(20.minutes))
      end

      def verify_event_source_token(source_token, card, event)
        verify_source_token(source_token, card, 20, event.end_datetime.since(20.days), event)
      end

      context "card exists" do
        let(:supporter) { create(:supporter, :has_a_card, nonprofit: nonprofit) }

        it "should properly add supporter card" do
          expect(supporter.cards.count).to eq(1)
          stripe_customer = nil
          expect(Stripe::Customer).to receive(:create).and_wrap_original { |m, *args|
            stripe_customer = m.call(*args)
            stripe_customer
          }
          card_data = {holder_type: "Supporter", holder_id: supporter.id, stripe_card_id: "card_88888", stripe_card_token: stripe_card_token, name: "card_name"}
          orig_card = supporter.cards.first
          card_ret = InsertCard.with_stripe(card_data)
          supporter.reload
          card = supporter.cards.where("cards.name = ?", "card_name").first

          expected_card = {
            id: card.id,
            name: "card_name",
            stripe_card_token: stripe_card_token,
            stripe_card_id: "card_88888",
            holder_id: supporter.id,
            holder_type: "Supporter",
            stripe_customer_id: stripe_customer["id"]
          }.merge(default_card_attribs).with_indifferent_access

          expect(card.attributes).to eq expected_card

          expect(supporter.cards.count).to eq(2)

          expect(Card.where("holder_id = ? and holder_type = ?", supporter.id, "Supporter").count).to eq(2)
          expect(Card.where("holder_id = ? and holder_type = ? and inactive != ?", supporter.id, "Supporter", false).count).to eq(0)

          expect(supporter.cards.find(orig_card.id)).to eq(orig_card)

          verify_cust_added_supporter(card.stripe_customer_id, supporter.id)

          verify_supporter_source_token(card_ret["token"], card)
        end

        it "should properly add card for event" do
          expect(supporter.cards.count).to eq(1)
          stripe_customer = nil
          expect(Stripe::Customer).to receive(:create).and_wrap_original { |m, *args|
            stripe_customer = m.call(*args)
            stripe_customer
          }
          card_data = {holder_type: "Supporter", holder_id: supporter.id, stripe_card_id: "card_88888", stripe_card_token: stripe_card_token, name: "card_name"}
          orig_card = supporter.cards.first
          card_ret = InsertCard.with_stripe(card_data, nil, event.id, user)
          supporter.reload
          card = supporter.cards.where("cards.name = ?", "card_name").first

          expected_card = {
            id: card.id,
            name: "card_name",
            stripe_card_token: stripe_card_token,
            stripe_card_id: "card_88888",
            holder_id: supporter.id,
            holder_type: "Supporter",
            stripe_customer_id: stripe_customer["id"]
          }.merge(default_card_attribs).with_indifferent_access

          expect(card.attributes).to eq expected_card

          expect(supporter.cards.count).to eq(2)

          expect(Card.where("holder_id = ? and holder_type = ?", supporter.id, "Supporter").count).to eq(2)
          expect(Card.where("holder_id = ? and holder_type = ? and inactive != ?", supporter.id, "Supporter", false).count).to eq(0)

          expect(supporter.cards.find(orig_card.id)).to eq(orig_card)

          verify_cust_added_supporter(card.stripe_customer_id, supporter.id)

          verify_event_source_token(card_ret["token"], card, event)
        end
      end

      context "card doesnt exist" do
        it "invalid params get ignored" do
          stripe_customer = nil
          expect(Stripe::Customer).to receive(:create).and_wrap_original { |m, *args|
            stripe_customer = m.call(*args)
            stripe_customer
          }
          card_data = {holder_type: "Supporter", holder_id: supporter.id, stripe_card_id: "card_88888", stripe_card_token: stripe_card_token,
                       name: "card_name", created_at: DateTime.new(0), updated_at: DateTime.new(0), inactive: true}

          card_ret = InsertCard.with_stripe(card_data)

          card = SourceToken.find(card_ret[:id]).tokenizable

          supporter.reload

          expected_card = {
            id: card.id,
            holder_type: "Supporter",
            holder_id: supporter.id,
            stripe_card_token: stripe_card_token,
            name: "card_name",
            stripe_card_id: "card_88888",
            stripe_customer_id: stripe_customer["id"]
          }.merge(default_card_attribs).with_indifferent_access

          expect(card.attributes).to eq expected_card

          verify_supporter_source_token(card_ret["token"], card)
        end

        it "should properly add supporter card when no card exist" do
          stripe_customer = nil
          expect(Stripe::Customer).to receive(:create).and_wrap_original { |m, *args|
            stripe_customer = m.call(*args)
            stripe_customer
          }

          card_data = {holder_type: "Supporter", holder_id: supporter.id, stripe_card_id: "card_88888", stripe_card_token: stripe_card_token, name: "card_name"}
          card_ret = InsertCard.with_stripe(card_data)
          supporter.reload
          card = supporter.cards.where("cards.name = ?", "card_name").first

          expected_card = {
            id: card.id,
            name: "card_name",
            stripe_card_id: "card_88888",
            stripe_card_token: stripe_card_token,
            stripe_customer_id: stripe_customer["id"],
            holder_type: "Supporter",
            holder_id: supporter.id
          }.merge(default_card_attribs).with_indifferent_access

          expect(card.attributes).to eq expected_card

          expect(supporter.cards.count).to eq(1)

          expect(Card.where("holder_id = ? and holder_type = ?", supporter.id, "Supporter").count).to eq(1)
          expect(Card.where("holder_id = ? and holder_type = ? and inactive != ?", supporter.id, "Supporter", false).count).to eq(0)
          verify_cust_added_supporter(card.stripe_customer_id, supporter.id)

          verify_supporter_source_token(card_ret["token"], card)
        end

        it "should properly add card for event" do
          stripe_customer = nil
          expect(Stripe::Customer).to receive(:create).and_wrap_original { |m, *args|
            stripe_customer = m.call(*args)
            stripe_customer
          }
          card_data = {holder_type: "Supporter", holder_id: supporter.id, stripe_card_id: "card_88888", stripe_card_token: stripe_card_token, name: "card_name"}
          card_ret = InsertCard.with_stripe(card_data, nil, event.id, user)
          supporter.reload
          card = supporter.cards.where("cards.name = ?", "card_name").first

          expected_card = {
            id: card.id,
            name: "card_name",
            stripe_card_token: stripe_card_token,
            stripe_card_id: "card_88888",
            holder_id: supporter.id,
            holder_type: "Supporter",
            stripe_customer_id: stripe_customer["id"]
          }.merge(default_card_attribs).with_indifferent_access

          expect(card.attributes).to eq expected_card

          expect(supporter.cards.count).to eq(1)

          expect(Card.where("holder_id = ? and holder_type = ?", supporter.id, "Supporter").count).to eq(1)
          expect(Card.where("holder_id = ? and holder_type = ? and inactive != ?", supporter.id, "Supporter", false).count).to eq(0)

          verify_cust_added_supporter(card.stripe_customer_id, supporter.id)

          verify_event_source_token(card_ret["token"], card, event)
        end
      end

      it "should return proper error when no supporter exists" do
        expect { InsertCard.with_stripe(holder_id: 5_555_555, holder_type: "Supporter", stripe_card_id: "card_fafjeht", stripe_card_token: stripe_card_token, name: "name") }
          .to raise_error(RuntimeError) { |error| expect(error.message).to eq "Sorry, you need to provide a nonprofit or supporter" }
      end

      it "should return proper error when you try to add using an event with unauthorized user" do
        expect {
          InsertCard.with_stripe({holder_id: supporter.id, holder_type: "Supporter", stripe_card_id: "card_fafjeht", stripe_card_token: stripe_card_token, name: "name"}, nil, event.id, user_not_from_nonprofit)
        }.to raise_error(AuthenticationError)
      end

      it "should return proper error when an invalid event_id is provided" do
        expect {
          InsertCard.with_stripe({holder_id: supporter.id, holder_type: "Supporter", stripe_card_id: "card_fafjeht",
         stripe_card_token: stripe_card_token, name: "name"}, nil, 55_555, user_not_from_nonprofit)
        }.to raise_error(RuntimeError) do |error|
          expect(error.message).to eq "Oops! There was an error: 55555 is not a valid event"
        end
      end

      it "should return proper error when event doesnt match the supporters nonprofit" do
        supporter2 = force_create(:supporter, nonprofit: force_create(:fv_poverty))
        expect {
          InsertCard.with_stripe({holder_id: supporter2.id, holder_type: "Supporter", stripe_card_id: "card_fafjeht", stripe_card_token: stripe_card_token, name: "name"},
            nil, event.id, user_not_from_nonprofit)
        }.to raise_error(RuntimeError) do |error|
          expect(error.message).to eq "Oops! There was an error: Event #{event.id} is not for the same nonprofit as supporter #{supporter2.id}"
        end
      end
    end

    def verify_cust_added(stripe_customer_id, holder_id, holder_type)
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      # does the customer exist? Was it set properly? Was the card set properly
      expect(customer).to_not be_nil
      expected_metadata = {
        holder_id: holder_id,
        holder_type: holder_type,
        cardholders_name: nil
      }

      expect(customer.metadata.to_hash).to eq expected_metadata
      customer
    end

    def verify_source_token(source_token, card, max_uses, expiration_time, event = nil)
      tok = SourceToken.where("token = ?", source_token).first
      expected = {
        created_at: Time.now,
        updated_at: Time.now,
        tokenizable_id: card.id,
        tokenizable_type: "Card",
        max_uses: max_uses,
        total_uses: 0,
        expiration: expiration_time,
        event_id: event ? event.id : nil,
        token: source_token
      }.with_indifferent_access

      expect(tok.attributes).to eq expected
    end
  end
end
