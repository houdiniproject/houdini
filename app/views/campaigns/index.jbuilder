# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
json.data @campaigns do |campaign|
  json.extract! campaign, :name, :total_raised, :goal_amount, :id
  json.url campaign_locateable_url(campaign)
end