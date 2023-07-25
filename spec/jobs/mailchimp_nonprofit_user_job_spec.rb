require 'rails_helper'

RSpec.describe MailchimpNonprofitUserJob, type: :job do
  let(:nonprofit) {create(:nonprofit_base)}
  let (:drip_email_list) {create(:drip_email_list_base)}

  it 'enqueues job when nonprofit user signed up' do 
    expect(Mailchimp).to receive(:signup).with('test@email.com', nonprofit)

    MailchimpNonprofitUserJob.perform_now('test@email.com', nonprofit)
  end 
end
