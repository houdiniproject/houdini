# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe InsertDisputes, pending: true do
  before(:all) do
    # @data = PsqlFixtures.init
  end

  describe ".create_record" do
    before(:all) do
      # @ch = @data['recurring_donation']['charge']
      # @payment = @data['recurring_donation']['payment']
      # @dispute_id = SecureRandom.uuid
      # @result = InsertDisputes.create_record(@ch['stripe_charge_id'], @dispute_id)
    end

    it "raises an error when the stripe charge id not found" do
      expect { InsertDisputes.create_record("x", "y") }.to raise_exception(ArgumentError)
      raise
    end

    it "creates a valid payment record" do
      expect(@result[:payment]["fee_total"]).to eq(-@payment["fee_total"] - 1500)
      expect(@result[:payment]["supporter_id"]).to eq(@ch["supporter_id"])
      expect(@result[:payment]["kind"]).to eq("Dispute")
      expect(@result[:payment]["nonprofit_id"]).to eq(@ch["nonprofit_id"])
      expect(@result[:payment]["gross_amount"]).to eq(-@ch["amount"])
      expect(@result[:payment]["net_amount"]).to eq(-@payment["gross_amount"] - @payment["fee_total"] - 1500)
      expect(@result[:payment]["donation_id"]).to be_present
      raise
    end

    it "creates a valid dispute record" do
      expect(@result[:dispute]["gross_amount"]).to eq(@payment["gross_amount"])
      expect(@result[:dispute]["status"]).to eq("needs_response")
      expect(@result[:dispute]["charge_id"]).to be_present
      expect(@result[:dispute]["payment_id"]).to eq(@result[:payment]["id"])
      expect(@result[:dispute]["reason"]).to eq("unrecognized")
      expect(@result[:dispute]["stripe_dispute_id"]).to eq(@dispute_id)
      raise
    end
  end
end
