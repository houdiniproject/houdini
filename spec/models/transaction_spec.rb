# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  include_context :shared_donation_charge_context

  describe 'to_builder' do 
    subject { supporter.transactions.create(amount: 1000).to_builder.attributes!}
    it 'will create a proper builder result' do 
      expect(subject).to match({
        'id' => match('trx_[a-zA-Z0-9]{22}'),
        'nonprofit' => nonprofit.id,
        'supporter' => supporter.id,
        'object' => 'transaction',
        'amount' => {
          'cents' => 1000,
          'currency' => 'usd'
        }
      })
    end
  end
end
