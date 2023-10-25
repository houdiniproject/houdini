# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Tracking < ApplicationRecord
  attr_accessible :utm_campaign, :utm_content, :utm_medium, :utm_source

  belongs_to :donation
end
