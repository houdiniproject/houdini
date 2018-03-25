require 'rails_helper.rb'

describe JobTypes::NonprofitPaymentNotificationJob do
  describe '.perform' do
    it 'calls the correct active mailer' do
      expect(DonationMailer).to receive(:nonprofit_payment_notification).with(1, nil).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::NonprofitPaymentNotificationJob.new(1)
      job.perform
    end

    it 'calls the correct active mailer, with user id' do
      expect(DonationMailer).to receive(:nonprofit_payment_notification).with(1, 2).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::NonprofitPaymentNotificationJob.new(1, 2)
      job.perform
    end
  end
end
