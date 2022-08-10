# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe CampaignGiftOption, type: :model do
  it {is_expected.to belong_to(:campaign).required(true)}
  it {is_expected.to have_many(:campaign_gifts)}
  it {is_expected.to have_many(:donations).through(:campaign_gifts)}
  it {is_expected.to have_one(:nonprofit).through(:campaign)}

  it {is_expected.to validate_presence_of(:name)}
end
