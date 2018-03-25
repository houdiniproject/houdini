require 'rails_helper.rb'

describe JobTypes::NonprofitAdminExistingInviteJob do
  describe '.perform' do
    it 'calls the correct active mailer' do
      expect(NonprofitAdminMailer).to receive(:existing_invite).with(1).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::NonprofitAdminExistingInviteJob.new(1)
      job.perform
    end
  end
end