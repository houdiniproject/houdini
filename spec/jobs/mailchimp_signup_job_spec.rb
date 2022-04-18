# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe MailchimpSignupJob, type: :job do

  it 'enqueues the job when provided with the correct email' do
    expect {
      MailchimpSignupJob.perform_later('fake@email.name', "fake_mailchimp_list_id")
    }.to have_enqueued_job.with('fake@email.name', "fake_mailchimp_list_id")
  end
 end
