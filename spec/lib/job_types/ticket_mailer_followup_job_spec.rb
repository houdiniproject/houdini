require 'rails_helper.rb'

describe JobTypes::TicketMailerFollowupJob do
  describe '.perform' do
    it 'calls the correct active mailer' do
      expect(TicketMailer).to receive(:followup).with(1,2 ).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::TicketMailerFollowupJob.new(1, 2)
      job.perform
    end
  end
end