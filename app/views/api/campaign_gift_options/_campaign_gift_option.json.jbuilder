# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(campaign_gift_option, :id, :name, :description, :deleted, :hide_contributions, :order, :to_ship, :quantity)

json.object "campaign_gift_option"

json.url api_nonprofit_campaign_campaign_gift_option_url(
  campaign_gift_option.nonprofit,
  campaign_gift_option.campaign,
  campaign_gift_option
)

json.gift_option_amount campaign_gift_option.gift_option_amounts do |desc|
  json.amount do
    json.partial! "/api/common/amount", amount: desc.amount
  end
  if desc.recurrence.present?
    json.recurrence do
      json.call(desc.recurrence, :type, :interval)
    end
  else
    json.recurrence nil
  end
end

json.nonprofit campaign_gift_option.nonprofit.id

json.campaign campaign_gift_option.campaign.id
