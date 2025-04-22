# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe JobTypes::NonprofitFirstDonationPaymentJob do
  include_context :shared_donation_charge_context
  describe ".perform" do
    let(:donation_without_np) { force_create(:donation) }
    let(:donation_without_charge) { force_create(:donation, nonprofit: nonprofit) }
    let(:charge) { force_create(:charge, nonprofit: nonprofit, donation: donation) }
    let(:donation) { force_create(:donation, nonprofit: nonprofit) }
    let(:misc_np_infos_no_first_charge_sent) { force_create(:miscellaneous_np_info, nonprofit: nonprofit) }

    let(:misc_np_infos_first_charge_sent) { force_create(:miscellaneous_np_info, nonprofit: nonprofit, first_charge_email_sent: true) }

    it "does not send email if nonprofit isnt found" do
      expect_job_not_queued
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation_without_np.id).perform
    end

    it "does not send email if charge isnt found" do
      expect_job_not_queued
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation_without_charge.id).perform
    end

    it "does not send email if nonprofit is found but first charge already sent" do
      misc_np_infos_first_charge_sent
      expect_job_not_queued
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation_without_np.id).perform
    end

    it "sends email when everything correct" do
      misc_np_infos_no_first_charge_sent
      expect_job_queued.with(JobTypes::NonprofitFirstChargeEmailJob, nonprofit.id)
      charge
      JobTypes::NonprofitFirstDonationPaymentJob.new(donation.id).perform
      misc_np_infos_no_first_charge_sent.reload
      expect(misc_np_infos_no_first_charge_sent.first_charge_email_sent).to be true
    end
  end
end
