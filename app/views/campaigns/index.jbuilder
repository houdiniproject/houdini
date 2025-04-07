# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @campaigns do |campaign|
  json.extract! campaign, :name, :total_raised, :goal_amount, :id
  json.url campaign_locateable_url(campaign)
end
