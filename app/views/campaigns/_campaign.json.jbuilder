# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.extract! campaign, :id, :name, # basics
  :nonprofit_id, :profile_id, :parent_campaign_id, # references
  :reason_for_supporting, :default_reason_for_supporting,
  :published, :deleted

json.url campaign_locateable_url(campaign)

if campaign.main_image.attached?
  json.main_image do
    json.full rails_storage_proxy_url(campaign.main_image)
    json.normal rails_storage_proxy_url(campaign.main_image_by_size(:normal))
    json.thumb rails_storage_proxy_url(campaign.main_image_by_size(:thumb))
  end
end

if campaign.background_image.attached?
  json.background_image do
    json.full rails_storage_proxy_url(campaign.background_image)
    json.normal rails_storage_proxy_url(campaign.background_image_by_size(:normal))
  end
end
