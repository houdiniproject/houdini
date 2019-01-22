# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe QueryDonations do

  describe :campaign_export do
    let(:nonprofit) {force_create(:nonprofit)}
    let(:supporter) {force_create(:supporter)}
    let(:campaign) {force_create(:campaign, nonprofit:nonprofit, show_total_count:false, show_total_raised: false, goal_amount: 16000)}
    let(:campaign_child) {force_create(:campaign, nonprofit:nonprofit, parent_campaign:campaign, show_total_count:true, show_total_raised: true, goal_amount: 8000)}

    let(:campaign_child_2) {force_create(:campaign, nonprofit:nonprofit, parent_campaign:campaign, show_total_count:true, show_total_raised: true, goal_amount: 4000 )}

    let(:donation) { force_create(:donation, campaign: campaign, amount: 1000, supporter:supporter)}
    let(:payment) { force_create(:payment, donation: donation, gross_amount:1000, supporter:supporter)}

    let(:donation2) { force_create(:donation, campaign: campaign, amount: 2000, supporter:supporter)}
    let(:payment2) { force_create(:payment, donation: donation2, gross_amount:2000, supporter:supporter)}

    let(:donation3) { force_create(:donation, campaign: campaign_child, amount: 2000, supporter:supporter)}
    let(:payment3) { force_create(:payment, donation: donation3, gross_amount:4000, kind:'RecurringPayment', supporter:supporter)}
    let(:payment3_1) { force_create(:payment, donation: donation3, gross_amount:2000, kind:'RecurringPayment', supporter:supporter)}
    let(:recurring) {force_create(:recurring_donation, donation: donation3, amount: 2000, supporter:supporter)}

    let(:donation4) { force_create(:donation, campaign: campaign_child_2, amount: 8000, supporter:supporter)}
    let(:payment4) { force_create(:payment, donation: donation4, gross_amount:8000, supporter:supporter)}

    let(:payments) do
      payment
      payment2
      payment3
      payment3_1
      recurring
      payment4
    end

    let (:campaign_export) do
      payments
      QueryDonations.campaign_export(campaign.id)

    end

    it 'payment amounts get the first payment, not additional ones' do
      export = vector_to_hash(campaign_export)

      expect(export.map{|i| i['Amount']}).to match_array(['$10.00', '$20.00', '$40.00', '$80.00'])
    end

     it 'includes the campaign ids' do
       export = vector_to_hash(campaign_export)
       expect(export.map{|i| i['Campaign Id']}).to match_array([campaign.id, campaign.id, campaign_child.id, campaign_child_2.id])
     end
  end

  ## move to common area
  def vector_to_hash(vecs)
    keys = vecs.first.to_a.map{|k| k.to_s.titleize}

    vecs.drop(1).map{|v| keys.zip(v).to_h}
  end

end
