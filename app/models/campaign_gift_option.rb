# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignGiftOption < ApplicationRecord
  attr_accessible \
    :amount_one_time, # int (cents)
    :amount_recurring, # int (cents)
    :amount_dollars, # str, gets converted to amount
    :description, # text
    :name, # str
    :campaign, # assocation
    :quantity, # int (optional)
    :to_ship, # boolean
    :order, # int (optional)
    :hide_contributions # boolean (optional)

  belongs_to :campaign, required: true
  has_many :campaign_gifts
  has_many :donations, through: :campaign_gifts
  has_one :nonprofit, through: :campaign

  validates :name, presence: true
  validates :amount_one_time, presence: true, numericality: {only_integer: true}, unless: :amount_recurring
  validates :amount_recurring, presence: true, numericality: {only_integer: true}, unless: :amount_one_time

  def total_gifts
    campaign_gifts.count
  end

  def gifts_available?
    quantity.nil? || quantity.zero? || total_gifts < quantity
  end

  def as_json(options = {})
    h = super
    h[:total_gifts] = total_gifts
    h
  end
end
