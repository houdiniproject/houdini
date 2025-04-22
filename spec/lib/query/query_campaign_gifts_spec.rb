# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe QueryCampaignGifts do
  GIFT_LEVEL_ONE_TIME = 1111
  GIFT_LEVEL_RECURRING = 5585
  GIFT_LEVEL_CHANGED_RECURRING = 5512
  CAMPAIGN_GIFT_OPTION_NAME = "theowthoinv"
  let(:np) { force_create(:nonprofit) }
  let(:supporter1) { force_create(:supporter, nonprofit: np) }
  let(:supporter2) { force_create(:supporter, nonprofit: np) }
  let(:campaign) { force_create(:campaign, nonprofit: np, slug: "slug stuff") }
  let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign, name: CAMPAIGN_GIFT_OPTION_NAME, amount_one_time: GIFT_LEVEL_ONE_TIME, amount_recurring: GIFT_LEVEL_RECURRING) }
  let(:campaign_gift1) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation1) }
  let(:donation1) { force_create(:donation, amount: GIFT_LEVEL_ONE_TIME, campaign: campaign, supporter: supporter1) }

  let(:payment1) { force_create(:payment, gross_amount: GIFT_LEVEL_ONE_TIME, donation: donation1) }

  let(:donation2) { force_create(:donation, amount: GIFT_LEVEL_CHANGED_RECURRING, campaign: campaign, supporter: supporter2) }
  let(:payment2) { force_create(:payment, gross_amount: GIFT_LEVEL_RECURRING, donation: donation2) }
  let(:payment3) { force_create(:payment, gross_amount: GIFT_LEVEL_CHANGED_RECURRING, donation: donation2) }
  let(:campaign_gift2) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation2) }
  let(:recurring) { force_create(:recurring_donation, donation: donation2, amount: GIFT_LEVEL_CHANGED_RECURRING) }

  let(:init_all) {
    np
    supporter1
    supporter2
    campaign_gift1
    campaign_gift2
    recurring
    payment1
    payment2
    payment3
    gift_level_match
  }
  let(:gift_level_match) {
    QueryCampaignGifts.report_metrics(campaign.id)
  }

  before(:each) {
    init_all
  }

  it "counts gift donations properly" do
    glm = gift_level_match

    data = glm[:data]

    expect(data).to eq([
      {
        "name" => CAMPAIGN_GIFT_OPTION_NAME,
        "total_donations" => 2,
        "total_one_time" => GIFT_LEVEL_ONE_TIME,
        "total_recurring" => GIFT_LEVEL_RECURRING
      }
    ])
  end
end
