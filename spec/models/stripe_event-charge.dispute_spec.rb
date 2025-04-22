# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe StripeEvent, type: :model do
  around(:each) do |example|
    Timecop.freeze(Date.new(2021, 5, 4)) do
      StripeMockHelper.mock do
        example.run
      end
    end
  end

  describe "charge.dispute.*" do
    describe "dispute.created" do
      include_context :dispute_created_specs
      let(:obj) {
        StripeEvent.process_dispute(event_json)
        StripeDispute.where("stripe_dispute_id = ?", json["id"]).first
      }
    end

    describe "dispute.funds_withdrawn" do
      include_context :dispute_funds_withdrawn_specs

      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where("stripe_dispute_id = ?", json["id"]).first
      end
    end

    describe "dispute.created AND funds_withdrawn at sametime" do
      include_context :dispute_created_and_withdrawn_at_same_time_specs
      let(:obj) do
        event_json_funds_withdrawn
        StripeEvent.process_dispute(event_json_created)
        StripeEvent.process_dispute(event_json_funds_withdrawn)
        StripeDispute.where("stripe_dispute_id = ?", json_funds_withdrawn["id"]).first
      end
    end

    describe "dispute.created AND funds_withdrawn in order" do
      include_context :dispute_created_and_withdrawn_in_order_specs
      let(:obj) do
        StripeEvent.process_dispute(event_json_created)
        StripeEvent.process_dispute(event_json_funds_withdrawn)
        StripeDispute.find_by(stripe_dispute_id: json_created["id"])
      end
    end

    describe "dispute.funds_reinstated" do
      include_context :dispute_funds_reinstated_specs
      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where("stripe_dispute_id = ?", json["id"]).first
      end
    end

    describe "dispute.closed, status = lost" do
      include_context :dispute_lost_specs

      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where("stripe_dispute_id = ?", json["id"]).first
      end
    end

    describe "dispute.created -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
      include_context :dispute_created_withdrawn_and_lost_in_order_specs

      let(:obj) do
        StripeEvent.process_dispute(event_json_created)
        StripeEvent.process_dispute(event_json_funds_withdrawn)
        StripeEvent.process_dispute(event_json_lost)
        StripeDispute.where("stripe_dispute_id = ?", json_lost["id"]).first
      end
    end

    describe "dispute.created-with-one-withdrawn -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
      include_context :dispute_created_with_withdrawn_and_lost_in_order_specs

      let(:obj) do
        StripeEvent.process_dispute(event_json_created)
        StripeEvent.process_dispute(event_json_funds_withdrawn)
        StripeEvent.process_dispute(event_json_lost)
        StripeDispute.where("stripe_dispute_id = ?", json_lost["id"]).first
      end
    end

    describe "dispute.closed, status = lost -> dispute.created -> dispute.funds_withdrawn" do
      include_context :dispute_lost_created_and_funds_withdrawn_at_same_time_spec

      let(:obj) do
        StripeEvent.process_dispute(event_json_lost)
        StripeEvent.process_dispute(event_json_created)
        StripeEvent.process_dispute(event_json_funds_withdrawn)
        StripeDispute.where("stripe_dispute_id = ?", json_lost["id"]).first
      end
    end

    describe "dispute.closed, status = won" do
      include_context :dispute_won_specs
      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where("stripe_dispute_id = ?", json["id"]).first
      end
    end

    describe "two disputes on the same transaction" do
      describe "partial1" do
        include_context :dispute_with_two_partial_disputes_withdrawn_at_same_time_spec__partial1
        let(:obj) do
          StripeEvent.process_dispute(event_json_dispute_partial1)
          StripeEvent.process_dispute(event_json_dispute_partial2)
          StripeDispute.where(stripe_dispute_id: json_partial1["id"]).first
        end
      end

      describe "partial2" do
        include_context :dispute_with_two_partial_disputes_withdrawn_at_same_time_spec__partial2
        let(:obj) do
          StripeEvent.process_dispute(event_json_dispute_partial1)
          StripeEvent.process_dispute(event_json_dispute_partial2)
          StripeDispute.where(stripe_dispute_id: json_partial2["id"]).first
        end
      end
    end

    describe "legacy dispute specs" do
      include_context :legacy_dispute_specs
      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where("stripe_dispute_id = ?", json["id"]).first
      end
    end
  end
end
