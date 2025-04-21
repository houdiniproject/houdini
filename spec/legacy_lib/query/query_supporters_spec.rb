# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe QuerySupporters do
  let(:gift_level_one_time) { 1111 }
  let(:gift_level_recurring) { 5585 }
  let(:gift_level_changed_recurring) { 5512 }
  let(:campaign_gift_option_name) { "theowthoinv" }

  let(:np) { force_create(:nm_justice) }
  let(:supporter1) { force_create(:supporter, nonprofit: np, name: "Cacau") }
  let(:supporter2) { force_create(:supporter, nonprofit: np, name: "Penelope") }
  let(:campaign) { force_create(:campaign, nonprofit: np, slug: "slug stuff") }
  let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign, name: campaign_gift_option_name, amount_one_time: gift_level_one_time, amount_recurring: gift_level_recurring) }
  let(:campaign_gift1) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation1) }

  let(:payment_utc_time) { Time.new(2021, 10, 10, 1, 1, 0, "+00:00") }
  let(:payment2_utc_time) { Time.new(2021, 1, 1, 1, 1, 0, "+00:00") }

  let(:donation1) { force_create(:donation, amount: gift_level_one_time, campaign: campaign, supporter: supporter1, date: payment_utc_time) }
  let(:donation4) { force_create(:donation, amount: gift_level_one_time, campaign: campaign, supporter: supporter1, date: payment2_utc_time) }
  let(:donation5) { force_create(:donation, amount: gift_level_one_time, campaign: campaign, supporter: supporter2, date: payment2_utc_time) }

  let(:payment1) { force_create(:payment, gross_amount: gift_level_one_time, donation: donation1, date: payment_utc_time) }

  let(:donation2) { force_create(:donation, amount: gift_level_changed_recurring, campaign: campaign, supporter: supporter2) }
  let(:payment2) { force_create(:payment, gross_amount: gift_level_recurring, donation: donation2) }
  let(:payment4) { force_create(:payment, gross_amount: gift_level_one_time, donation: donation4, date: payment2_utc_time) }
  let(:payment5) { force_create(:payment, gross_amount: gift_level_one_time, donation: donation5, date: payment2_utc_time) }

  let(:payment3) { force_create(:payment, gross_amount: gift_level_changed_recurring, donation: donation2) }
  let(:campaign_gift2) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation2) }
  let(:recurring) { force_create(:recurring_donation, donation: donation2, amount: gift_level_changed_recurring) }

  let(:note_content_1) do
    "CONTENT1"
  end

  let(:note_content_2) do
    "CONTENT2"
  end

  let(:note_content_3) do
    "CONTENT3"
  end

  let(:supporter_note_for_s1) do
    force_create(:supporter_note, supporter: supporter1, created_at: DateTime.new(2018, 1, 5), content: note_content_1)
  end

  let(:supporter_note_1_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2018, 2, 5), content: note_content_2)
  end

  let(:supporter_note_2_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2020, 4, 5), content: note_content_3)
  end

  let(:init_all) do
    np
    supporter1
    supporter2
    campaign_gift1
    campaign_gift2
    recurring
    payment1
    payment2
    payment3
  end

  let(:campaign_list) do
    QuerySupporters.campaign_list(np.id, campaign.id, page: 0)
  end

  it "counts gift donations properly" do
    init_all
    glm = campaign_list

    data = glm[:data]

    expect(data.map { |i| i["total_raised"] }).to match_array([gift_level_one_time, gift_level_recurring])
  end

  describe ".supporter_note_export_enumerable" do
    let(:lazy_enumerable) do
      supporter_note_for_s1
      supporter_note_1_for_s2
      supporter_note_2_for_s2
      QuerySupporters.supporter_note_export_enumerable(np.id, {})
    end

    it "is a lazy enumerable" do
      expect(lazy_enumerable).to be_a Enumerator::Lazy
    end

    it "is three items long" do
      expect(lazy_enumerable.to_a.size).to eq 4
    end

    it "has correct headers" do
      expect(lazy_enumerable.to_a.first).to eq ["Id", "Email", "Note Created At", "Note Contents"]
    end
  end

  describe ".full_search" do
    before do
      supporter1.payments = [payment1, payment4]
      supporter2.payments = [payment5]
    end

    it "returns the UTC date when the timezone is not specified" do
      result = QuerySupporters.full_search(np.id, {search: "Cacau"})
      expect(result[:data].first["last_contribution"]).to eq(payment_utc_time.strftime("%m/%d/%y"))
    end

    it "returns the converted date when the timezone is specified" do
      np.update(timezone: "America/New_York")
      result = QuerySupporters.full_search(np.id, {search: "Cacau"})
      expect(result[:data].first["last_contribution"]).to eq((payment_utc_time - 1.day).strftime("%m/%d/%y"))
    end

    it "finds the payments on dates after the specified dates" do
      np.update(timezone: "America/New_York")
      result = QuerySupporters.full_search(np.id, {last_payment_after: (payment2_utc_time + 1.day).to_s})
      expect(result[:data].count).to eq 1
    end

    it "finds the payments on dates before the specified dates" do
      np.update(timezone: "America/New_York")
      result = QuerySupporters.full_search(np.id, {last_payment_before: payment_utc_time.to_s})
      expect(result[:data].count).to eq 2
    end
  end
end
