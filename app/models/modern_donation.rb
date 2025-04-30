# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# ModernDonation represents a single donation event associated with a transaction. Everytime a
# a recurring donation is ran, it will create a new ModernDonation. This varies from how
# Donation works.
class ModernDonation < ApplicationRecord
  include Model::TrxAssignable
  setup_houid :don, :houid

  # TODO must associate with events and campaigns somehow

  # NOTE: REMEMBER a Donation does not necessarily represent a single event. It could represent info
  # about a recurring donation as well. No, this isn't great.
  belongs_to :legacy_donation, class_name: "Donation", foreign_key: :donation_id

  delegate :designation, :dedication, :comment, to: :legacy_donation

  as_money :amount

  def dedication
    JSON.parse legacy_donation.dedication
  rescue
    nil
  end

  # REMEMBER: multiple ModernDonations could have the same legacy_id
  def legacy_id
    legacy_donation.id
  end

  def publish_created
    object_events.create(event_type: "donation.created")
  end

  def publish_updated
    object_events.create(event_type: "donation.updated")
  end

  def publish_deleted
    object_events.create(event_type: "donation.deleted")
  end
end
