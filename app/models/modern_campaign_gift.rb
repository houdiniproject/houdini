# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ModernCampaignGift < ApplicationRecord
  include Model::Houidable
  include Model::Jbuilder
  include Model::Eventable
  setup_houid :cgift

  belongs_to :campaign_gift_purchase
  belongs_to :legacy_campaign_gift, class_name: "CampaignGift", foreign_key: :campaign_gift_id, inverse_of: :modern_campaign_gift

  has_one :campaign_gift_option, through: :legacy_campaign_gift
  has_one :trx, through: :campaign_gift_purchase
  has_one :supporter, through: :campaign_gift_purchase
  has_one :nonprofit, through: :campaign_gift_purchase
  has_one :campaign, through: :campaign_gift_purchase

  # TODO replace with Discard gem
  define_model_callbacks :discard

  # after_discard :publish_deleted

  validates :amount, presence: true
  validates :legacy_campaign_gift, presence: true
  validates :campaign_gift_purchase, presence: true

  # TODO replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :deleted)
      json.object "campaign_gift"

      json.add_builder_expansion :nonprofit, :supporter, :campaign, :campaign_gift_option
      json.add_builder_expansion :trx,
        json_attribute: :transaction

      if expand.include? :campaign_gift_purchase
        json.campaign_gift_purchase campaign_gift_purchase.to_builder
      else
        json.campaign_gift_purchase campaign_gift_purchase.id
      end

      json.amount do
        json.cents amount
        json.currency nonprofit.currency
      end
    end
  end

  def publish_created
    Houdini.event_publisher.announce(:campaign_gift_created, to_event("campaign_gift.created", :nonprofit, :supporter, :trx, :campaign, :campaign_gift_option, :campaign_gift_purchase).attributes!)
  end

  def publish_updated
    Houdini.event_publisher.announce(:campaign_gift_updated, to_event("campaign_gift.updated", :nonprofit, :supporter, :trx, :campaign, :campaign_gift_option, :campaign_gift_purchase).attributes!)
  end

  def publish_deleted
    Houdini.event_publisher.announce(:campaign_gift_deleted, to_event("campaign_gift.deleted", :nonprofit, :supporter, :trx, :campaign, :campaign_gift_option, :campaign_gift_purchase).attributes!)
  end
end
