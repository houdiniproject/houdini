require 'rails_helper'

RSpec.describe MailchimpNonprofitUserJob, type: :job do
  let(:user) {create(:user)}
  let(:nonprofit) {create(:nonprofit_base)}
  let(:drip_email_list) {create(:drip_email_list_base)}

  it 'enqueues job when nonprofit user signed up' do 
    expect(Mailchimp).to receive(:signup).with(user, nonprofit)

    MailchimpNonprofitUserJob.perform_now(drip_email_list, user , nonprofit)
  end 
end
