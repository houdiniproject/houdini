require 'rails_helper'
require 'webmock/rspec'


RSpec.describe MailchimpNonprofitUserAddJob, type: :job do
  let(:user) {create(:user)}
  let(:nonprofit) {create(:nonprofit_base)}
  let(:drip_email_list) {create(:drip_email_list_base)}

  it 'enqueues job when nonprofit user signed up' do 
    expect(Mailchimp).to receive(:signup_nonprofit_user).with(drip_email_list, user, nonprofit)

   MailchimpNonprofitUserAddJob.perform_now(drip_email_list, user , nonprofit)
  end 
end
