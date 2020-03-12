# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper.rb'

describe JobTypes::NonprofitFirstDonationPaymentJob do
  include_context :shared_donation_charge_context
  describe '.perform' do

    let(:donation_without_np) { force_create(:donation)}
    let(:donation_without_charge) { force_create(:donation, nonprofit: nonprofit)}

    let(:earlier_charge) { force_create(:charge, nonprofit: nonprofit)}
    let(:charge) {force_create(:charge, nonprofit: nonprofit, donation: donation)}
    let(:donation) {force_create(:donation, nonprofit: nonprofit)}
    
    it 'does not send email if nonprofit isnt found' do
      expect_job_not_queued
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation_without_np).perform
    end

    it 'does not send email if charge isnt found' do
      expect_job_not_queued
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation_without_charge).perform
    end
    
    it 'does not send email if charge is not the first charge for nonprofit' do
      expect_job_not_queued
      earlier_charge
      charge
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation).perform
    end

    it 'sends email when everything correct' do
      expect_job_queued.with(JobTypes::NonprofitFirstChargeEmail, nonprofit.id, charge.id)
      charge
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation).perform
    end
    
  end
end