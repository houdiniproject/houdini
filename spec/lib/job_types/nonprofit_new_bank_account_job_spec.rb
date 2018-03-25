require 'rails_helper.rb'

describe JobTypes::NonprofitNewBankAccountJob do
  describe '.perform' do
    it 'calls the correct active mailer' do
      expect(NonprofitMailer).to receive(:new_bank_account_notification).with(1).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::NonprofitNewBankAccountJob.new(1)
      job.perform
    end
  end
end