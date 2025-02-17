# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ModernDonation < ApplicationRecord
  include Model::TrxAssignable
  setup_houid :don

  # TODO must associate with events and campaigns somehow
  belongs_to :legacy_donation, class_name: "Donation", foreign_key: :donation_id, inverse_of: :modern_donations

  delegate :designation, :dedication, to: :legacy_donation

  def to_id
    ::Jbuilder.new do |json|
      json.id id
      json.object "donation"
      json.type "trx_assignment"
    end
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :designation)
      json.object "donation"
      json.type "trx_assignment"

      if dedication
        json.dedication do
          json.type dedication["type"]
          json.name dedication["name"]
          contact = dedication["contact"]
          if contact
            json.contact do
              json.email contact["email"] if contact["email"]
              json.address contact["address"] if contact["address"]
              json.phone contact["phone"] if contact["phone"]
            end
          end
        end
      end
      # TODO the line above is a hacky solution

      json.amount do
        json.cents amount
        json.currency nonprofit.currency
      end

      json.add_builder_expansion :nonprofit, :supporter
      json.add_builder_expansion :trx, json_attribute: :transaction
    end
  end

  def publish_created
    Houdini.event_publisher.announce(:donation_created, to_event("donation.created", :nonprofit, :supporter, :trx).attributes!)
    Houdini.event_publisher.announce(:trx_assignment_created, to_event("trx_assignment.created", :nonprofit, :supporter, :trx).attributes!)
  end

  def publish_updated
    Houdini.event_publisher.announce(:donation_updated, to_event("donation.updated", :nonprofit, :supporter, :trx).attributes!)
    Houdini.event_publisher.announce(:trx_assignment_updated, to_event("trx_assignment.updated", :nonprofit, :supporter, :trx).attributes!)
  end
end
