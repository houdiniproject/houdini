# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class ModernDonation < ApplicationRecord
  include Model::TrxAssignable
  setup_houid :don

	# TODO must associate with events and campaigns somehow
	belongs_to :legacy_donation, class_name: 'Donation', foreign_key: :donation_id, inverse_of: :modern_donation

	delegate :designation, :dedication, to: :legacy_donation
	
	def to_builder(*expand)
    init_builder(*expand) do |json|
      json.(self, :id, :designation)
			json.object 'donation'

			json.dedication do
				json.type dedication['type']
				json.name dedication['name']
				contact = dedication['contact']
				json.contact do 
					json.email contact['email'] if contact['email'] 
					json.address contact['address'] if contact['address']
					json.phone contact['phone'] if contact['phone'] 
				end if contact
			end if dedication
			# TODO the line above is a hacky solution

      json.amount do
        json.value_in_cents amount
        json.currency nonprofit.currency
      end
    end
  end

  def publish_created
    Houdini.event_publisher.announce(:donation_created, to_event('donation.created', :nonprofit, :supporter, :trx).attributes!)
	end
	
	def publish_updated
		Houdini.event_publisher.announce(:donation_updated, to_event('donation.updated', :nonprofit, :supporter, :trx).attributes!)
	end
end
