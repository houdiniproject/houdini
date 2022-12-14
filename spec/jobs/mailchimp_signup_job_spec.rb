# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe MailchimpSignupJob, type: :job do
  let(:mailchimp_list) { create(:email_list_base)}
  it 'enqueues the job when provided with the correct email' do
    expect(Mailchimp).to receive(:signup).with('fake@email.name', mailchimp_list.id)
    
    MailchimpSignupJob.perform_now('fake@email.name', mailchimp_list)
    
  end
 end
