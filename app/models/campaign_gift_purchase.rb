# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CampaignGiftPurchase < ApplicationRecord
  include Model::Houidable
  include Model::Jbuilder
  include Model::Eventable

  setup_houid :cgpur

  belongs_to :campaign
  has_many :campaign_gifts, class_name: 'ModernCampaignGift'

  add_builder_expansion :nonprofit, :supporter, :campaign
  add_builder_expansion :trx, 
		json_attrib: :transaction
		
	has_one :transaction_assignment, as: :assignable
	has_one :trx, through: :transaction_assignment
	has_one :supporter, through: :trx
	has_one :nonprofit, through: :supporter


  # TODO replace with Discard gem
	define_model_callbacks :discard

  validates :amount, presence: true
  validates :campaign, presence: true
  validates :campaign_gifts, length: { minimum: 1 }
  
  # TODO replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.(self, :id, :deleted)
      json.object 'campaign_gift_purchase'
      
      json.amount do
        json.value_in_cents amount
        json.currency nonprofit.currency
      end

      if expand.include? :campaign_gifts
        json.campaign_gifts campaign_gifts do |gift|
          json.merge! gift.to_builder.attributes!
        end
      else
        json.campaign_gifts campaign_gifts.pluck(:id)
      end
    end
  end

  def publish_created
    Houdini.event_publisher.announce(:campaign_gift_purchase_created, to_event('campaign_gift_purchase.created', :nonprofit, :supporter, :trx, :campaign, :campaign_gifts).attributes!)
	end
	
	def publish_updated
		Houdini.event_publisher.announce(:campaign_gift_purchase_updated, to_event('campaign_gift_purchase.updated', :nonprofit, :supporter, :trx, :campaign, :campaign_gifts).attributes!)
	end

	def publish_deleted
		Houdini.event_publisher.announce(:campaign_gift_purchase_deleted, to_event('campaign_gift_purchase.deleted', :nonprofit, :supporter, :trx, :campaign, :campaign_gifts).attributes!)
	end
end
