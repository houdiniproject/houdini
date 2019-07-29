# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe MigrateTicketOrder do
  let(:nonprofit) { force_create(:nonprofit)}
  let(:event) {force_create(:event, nonprofit: nonprofit)}
  let!(:supporter_no_address) {force_create(:supporter, nonprofit: nonprofit, address: "", country: nil)}

  let!(:supporter_with_address) {force_create(:supporter, nonprofit: nonprofit, address: "addy", city: 'city', state_code: 'state', zip_code: 'zip', country: 'country')}
  let!(:ticket_without_1) {force_create(:ticket, supporter: supporter_no_address, event:event)}
  let!(:ticket_without_2){ force_create(:ticket, supporter:supporter_with_address)}

  let(:payment) { force_create(:payment, supporter: supporter_with_address)}
  let(:payment_2) { force_create(:payment, supporter: supporter_no_address)}
  let!(:ticket_with_1) { force_create(:ticket, supporter:supporter_with_address, payment: payment)}
  let!(:ticket_with_2) { force_create(:ticket, supporter:supporter_with_address, payment: payment)}

  let!(:ticket_with_3) { force_create(:ticket, supporter:supporter_no_address, payment: payment_2)}

  describe '.from_ticket_to_orders' do
    before(:each) do
      MigrateTicketOrder.from_ticket_to_orders

      ticket_with_1.reload
      ticket_with_2.reload
      ticket_with_3.reload
      ticket_without_1.reload
      ticket_without_2.reload
    end

    it 'has individual TicketOrders for tickets without payment' do
      expect(ticket_without_1.ticket_order).to_not eq ticket_without_2.ticket_order
    end

    it 'has no address on TicketOrder if the supporter has no address' do
      expect(ticket_without_1.ticket_order.address).to be_nil
    end

    it 'has an address on a TicketOrder if the supporter has an address' do
      expect(ticket_without_2.ticket_order.address.address).to eq 'addy'
      expect(ticket_without_2.ticket_order.address.city).to eq 'city'
      expect(ticket_without_2.ticket_order.address.state_code).to eq 'state'
      expect(ticket_without_2.ticket_order.address.zip_code).to eq 'zip'
      expect(ticket_without_2.ticket_order.address.country).to eq 'country'
    end  
    
    it 'has the same TicketOrder for two tickets with same payment' do
      expect(ticket_with_1.ticket_order).to eq ticket_with_2.ticket_order
    end

    it 'has a different TicketOrder for two tickets with different payments' do
      expect(ticket_with_3.ticket_order).to_not eq ticket_with_2.ticket_order
    end

    it 'has no address on a TicketOrder where the supporter has no address' do
      expect(ticket_with_3.ticket_order.address).to be_nil
    end

    it 'has address on a TicketOrder where the supporter has address' do
      expect(ticket_with_1.ticket_order.address.address).to eq 'addy'
      expect(ticket_with_1.ticket_order.address.city).to eq 'city'
      expect(ticket_with_1.ticket_order.address.state_code).to eq 'state'
      expect(ticket_with_1.ticket_order.address.zip_code).to eq 'zip'
      expect(ticket_with_1.ticket_order.address.country).to eq 'country'
    end
  end
end