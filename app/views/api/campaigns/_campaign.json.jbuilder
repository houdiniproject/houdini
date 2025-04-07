# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(campaign, :id, :name)

json.object "campaign"

json.url api_nonprofit_campaign_url(campaign.nonprofit, campaign)

json.nonprofit campaign.nonprofit.id
