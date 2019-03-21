# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper.rb'

describe JobTypes::ExportSupporterNotesCompletedJob do
  describe '.perform' do
    it 'calls the correct active mailer' do
      input = 1
      expect(ExportMailer).to receive(:export_supporter_notes_completed_notification).with(input).and_wrap_original{|m, *args|  mailer = double('object'); expect(mailer).to receive(:deliver).and_return(nil); mailer}

      job = JobTypes::ExportSupporterNotesCompletedJob.new(1)
      job.perform
    end
  end
end