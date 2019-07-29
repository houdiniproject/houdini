require 'rails_helper'

RSpec.describe TicketOrder, :type => :model do
  let(:ticket_order1) { force_create(:ticket_order, supporter:supporter)}
  let(:supporter) {force_create(:supporter)}

  describe 'ticket addresses' do
    it 'has no address on any ticket' do
      expect(ticket_order1.address).to be_nil
    end

    describe 'address added' do
      let(:addy) { ticket_order1.create_address(address: "something", supporter:supporter) }

      it 'has a valid address' do
        addy.errors.select{|i| puts i}
        expect(addy.valid?).to eq true
      end

      it 'has valid attributes' do 
        expect(addy.address).to eq "something"
        expect(addy.transactionable).to eq ticket_order1
      end
    end
  end
end
