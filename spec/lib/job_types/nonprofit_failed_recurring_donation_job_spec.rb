require 'rails_helper.rb'

describe JobTypes::NonprofitFailedRecurringDonationJob do
  describe '.perform' do
    it 'calls the correct active mailer' do
      expect(DonationMailer).to receive(:nonprofit_failed_recurring_donation).with(1).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::NonprofitFailedRecurringDonationJob.new(1)
      job.perform
    end
  end
end