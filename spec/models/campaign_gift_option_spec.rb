# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe CampaignGiftOption, "type" => :model do
  include_context :shared_donation_charge_context
  let(:name) { "CUSTOM GIFT OPTION" }
  let(:amount_one_time) { 400 }
  let(:amount_recurring) { 100 }
  let(:description) { " Fun description!" }
  let(:to_ship) { true }
  let(:order) { 3 }

  let(:campaign_gift_option) do
    campaign.campaign_gift_options.create(description: description,
      amount_one_time: amount_one_time, amount_recurring: amount_recurring,
      name: name, to_ship: to_ship, order: order)
  end

  # campaign_gift_option with quantity but no to_ship
  let(:campaign_gift_option_2) do
    campaign.campaign_gift_options.create(description: description,
      amount_one_time: amount_one_time, amount_recurring: amount_recurring,
      name: name, quantity: 40, hide_contributions: true, order: order)
  end

  describe "validate" do
    it "has no errors on first example" do
      expect(campaign_gift_option.errors).to be_empty
    end

    it "has no errors on second example" do
      expect(campaign_gift_option_2.errors).to be_empty
    end
  end

  describe "create" do
    it "announces create for first example" do
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_created, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "campaign_gift_option.created",
        "data" => {
          "object" => {
            "campaign" => {
              "id" => campaign.id,
              "name" => campaign.name,
              "nonprofit" => nonprofit.id,
              "object" => "campaign"
            },
            "deleted" => false,
            "description" => description,
            "gift_option_amount" => [
              {
                "amount" => {"cents" => amount_one_time, "currency" => nonprofit.currency},
                "recurrence" => nil
              },
              {
                "amount" => {"cents" => amount_recurring, "currency" => nonprofit.currency},
                "recurrence" => {"interval" => 1, "type" => "monthly"}
              }
            ],
            "id" => kind_of(Numeric),
            "hide_contributions" => false,
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "campaign_gift_option",
            "order" => order,
            "to_ship" => true
          }
        }
      })

      campaign_gift_option
    end

    it "announces create for second example" do
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_created, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "campaign_gift_option.created",
        "data" => {
          "object" => {
            "campaign" => {
              "id" => campaign.id,
              "name" => campaign.name,
              "nonprofit" => nonprofit.id,
              "object" => "campaign"
            },
            "deleted" => false,
            "description" => description,
            "gift_option_amount" => [
              {
                "amount" => {"cents" => amount_one_time, "currency" => nonprofit.currency},
                "recurrence" => nil
              },
              {
                "amount" => {"cents" => amount_recurring, "currency" => nonprofit.currency},
                "recurrence" => {"interval" => 1, "type" => "monthly"}
              }
            ],
            "id" => kind_of(Numeric),
            "hide_contributions" => true,
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "campaign_gift_option",
            "order" => order,
            "quantity" => 40,
            "to_ship" => false
          }
        }
      })

      campaign_gift_option_2
    end
  end

  describe "update" do
    let(:cgo_update) do
      campaign_gift_option.amount_one_time = nil
      campaign_gift_option.save
      campaign_gift_option
    end

    let(:cgo2_update) do
      campaign_gift_option_2.amount_recurring = nil
      campaign_gift_option_2.hide_contributions = false
      campaign_gift_option_2.save
      campaign_gift_option_2
    end

    it "is without error on first example" do
      expect(cgo_update.errors).to be_empty
    end

    it "announces update for first example" do
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_updated, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "campaign_gift_option.updated",
        "data" => {
          "object" => {
            "campaign" => {
              "id" => campaign.id,
              "name" => campaign.name,
              "nonprofit" => nonprofit.id,
              "object" => "campaign"
            },
            "deleted" => false,
            "description" => description,
            "gift_option_amount" => [
              {
                "amount" => {"cents" => amount_recurring, "currency" => nonprofit.currency},
                "recurrence" => {"interval" => 1, "type" => "monthly"}
              }
            ],
            "id" => kind_of(Numeric),
            "hide_contributions" => false,
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "campaign_gift_option",
            "order" => order,
            "to_ship" => true
          }
        }
      }).ordered

      cgo_update
    end

    it "is without error on second example" do
      expect(cgo_update.errors).to be_empty
    end

    it "announces update for second example" do
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_updated, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "campaign_gift_option.updated",
        "data" => {
          "object" => {
            "campaign" => {
              "id" => campaign.id,
              "name" => campaign.name,
              "nonprofit" => nonprofit.id,
              "object" => "campaign"
            },
            "deleted" => false,
            "description" => description,
            "gift_option_amount" => [
              {
                "amount" => {"cents" => amount_one_time, "currency" => nonprofit.currency},
                "recurrence" => nil
              }
            ],
            "id" => kind_of(Numeric),
            "hide_contributions" => false,
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "campaign_gift_option",
            "order" => order,
            "quantity" => 40,
            "to_ship" => false
          }
        }
      }).ordered

      cgo2_update
    end
  end

  describe "deleted" do
    it "is without error on first example" do
      campaign_gift_option.destroy
      expect(campaign_gift_option).to_not be_persisted
    end

    it "announces deleted for first example" do
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_deleted, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "campaign_gift_option.deleted",
        "data" => {
          "object" => {
            "campaign" => {
              "id" => campaign.id,
              "name" => campaign.name,
              "nonprofit" => nonprofit.id,
              "object" => "campaign"
            },
            "deleted" => true,
            "description" => description,
            "gift_option_amount" => [
              {
                "amount" => {"cents" => amount_one_time, "currency" => nonprofit.currency},
                "recurrence" => nil
              },
              {
                "amount" => {"cents" => amount_recurring, "currency" => nonprofit.currency},
                "recurrence" => {"interval" => 1, "type" => "monthly"}
              }
            ],
            "id" => kind_of(Numeric),
            "hide_contributions" => false,
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "campaign_gift_option",
            "order" => order,
            "to_ship" => true
          }
        }
      })

      campaign_gift_option.destroy
    end

    it "is without error on second example" do
      campaign_gift_option_2.destroy
      expect(campaign_gift_option_2).to_not be_persisted
    end

    it "announces deleted for second example" do
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_create, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_option_deleted, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "campaign_gift_option.deleted",
        "data" => {
          "object" => {
            "campaign" => {
              "id" => campaign.id,
              "name" => campaign.name,
              "nonprofit" => nonprofit.id,
              "object" => "campaign"
            },
            "deleted" => true,
            "description" => description,
            "gift_option_amount" => [
              {
                "amount" => {"cents" => amount_one_time, "currency" => nonprofit.currency},
                "recurrence" => nil
              },
              {
                "amount" => {"cents" => amount_recurring, "currency" => nonprofit.currency},
                "recurrence" => {"interval" => 1, "type" => "monthly"}
              }
            ],
            "id" => kind_of(Numeric),
            "hide_contributions" => true,
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "campaign_gift_option",
            "order" => order,
            "quantity" => 40,
            "to_ship" => false
          }
        }
      })

      campaign_gift_option_2.destroy
    end
  end

  describe "#gift_option_amounts" do
    subject(:goa) { campaign_gift_option.gift_option_amounts }

    it { expect(goa.count).to eq 2 }

    describe "has a proper one time amount" do
      subject { goa.detect { |i| i.recurrence.nil? } }

      it {
        is_expected.to have_attributes(
          amount: have_attributes(
            cents: amount_one_time,
            currency: nonprofit.currency
          )
        )
      }

      it {
        is_expected.to have_attributes(recurrence: nil)
      }
    end

    describe "has a proper one time amount" do
      subject { goa.detect { |i| !i.recurrence.nil? } }

      it {
        is_expected.to have_attributes(
          amount: have_attributes(
            cents: amount_recurring,
            currency: nonprofit.currency
          )
        )
      }

      it {
        is_expected.to have_attributes(recurrence:
          have_attributes(interval: 1, type: "monthly"))
      }
    end
  end
end
