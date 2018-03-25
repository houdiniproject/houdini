require 'rails_helper.rb'

describe JobTypes::DonorPaymentNotificationJob do
  describe '.perform' do
    it 'calls the correct active mailer' do
      expect(DonationMailer).to receive(:donor_payment_notification).with(1,2).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::DonorPaymentNotificationJob.new(1,2)
      job.perform
    end
  end
end
