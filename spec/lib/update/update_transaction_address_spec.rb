# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe UpdateTransactionAddress do
  include_context :shared_donation_charge_context
  describe '.from_input' do
    describe 'type checking' do
      it 'nil for address causes error' do
        expect { subject.from_input(nil, nil)}.to raise_error ArgumentError
      end

      it 'CustomAddress for address causes error' do
        ca = CustomAddress.create!(address:" something", supporter: supporter, )
        expect { subject.from_input(nil, ca)}.to raise_error ArgumentError
      end
    end

    it 'create a new transaction address' do
      address1 = TransactionAddress.create!(address: "address 1", supporter: supporter)
      address2 = TransactionAddress.create!(address: "address 2", supporter: supporter)
      result = subject.from_input({address: "address 3"}, address1)

      expect(result).to_not eq address1
      expect(result).to_not eq address2
    end

    it 'select a different transaction address' do
      address1 = TransactionAddress.create!(address: "address 1", supporter: supporter)
      address2 = TransactionAddress.create!(address: "address 2", supporter: supporter)
      result = subject.from_input({address: "address 2"}, address1)

      expect(result).to eq address2
    end
  end
end