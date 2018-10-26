# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignCustomization < ActiveRecord::Base
  # attr_accessible :title, :b
  attr_accessible :starting_donors, #integer, number of donors to start with
                  :show_donors #boolean, true if you want to measure success based on donors instead of amount

  belongs_to :campaign
end
