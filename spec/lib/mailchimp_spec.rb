# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe Mailchimp do
  describe '.hard_sync_list' do
    let(:ret_val) do
      [{ id: 'on_both', email_address: 'on_both@email.com' },
       { id: 'on_mailchimp', email_address: 'on_mailchimp@email.com' }]
    end

    let(:np) { force_create(:nonprofit) }
    let(:tag_master) { force_create(:tag_master, nonprofit: np) }
    let(:email_list) { force_create(:email_list, mailchimp_list_id: 'list_id', tag_master: tag_master, nonprofit: np, list_name: 'temp') }
    let(:supporter_on_both) { force_create(:supporter, nonprofit: np, email: 'on_BOTH@email.com') }
    let(:supporter_on_local) { force_create(:supporter, nonprofit: np, email: 'on_local@email.com') }
    let(:tag_join) { force_create(:tag_join, tag_master: tag_master, supporter: supporter_on_both) }

    let(:tag_join2) { force_create(:tag_join, tag_master: tag_master, supporter: supporter_on_local) }

    it 'excepts when excepting' do
      expect(Mailchimp).to receive(:get_list_mailchimp_subscribers).with(email_list).and_raise

      expect { Mailchimp.generate_batch_ops_for_hard_sync(email_list) }.to raise_error
    end

    it 'passes' do
      tag_join
      tag_join2
      email_list

      expect(Mailchimp).to receive(:get_list_mailchimp_subscribers).with(email_list).and_return(ret_val)

      result = Mailchimp.generate_batch_ops_for_hard_sync(email_list)

      expect(result).to contain_exactly(
        {
          method: 'POST',
          path: 'lists/list_id/members',
          body: { email_address: supporter_on_local.email, status: 'subscribed' }.to_json
        },
        method: 'DELETE',
        path: 'lists/list_id/members/on_mailchimp'
      )
    end
  end
end
