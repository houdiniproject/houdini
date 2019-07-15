# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  let(:payment1) { force_create(:payment)}
  let(:payment2) { force_create(:payment)}
  let(:ticket_order1) {force_create(:ticket_order)}
  let(:ticket_order2) {force_create(:ticket_order)}
  let(:ticket1) { force_create(:ticket, payment: payment1, ticket_order:ticket_order1)}
  let(:ticket2) { force_create(:ticket, payment: payment1, ticket_order:ticket_order1)}
  let(:ticket3) { force_create(:ticket, payment: payment1, ticket_order:ticket_order1)}
  let(:ticket4) { force_create(:ticket, payment: payment2, ticket_order: ticket_order2)}

  before(:each) do
    ticket1 
    ticket2 
    ticket3 
    ticket4 
  end

  it 'has ticket1 getting ticket2 and ticket3 for related_tickets' do
    expect(ticket1.tickets_on_order).to contain_exactly(ticket1, ticket2, ticket3)
  end

  it 'has ticket2 getting ticket1 and ticket3 for tickets_on_order' do
    expect(ticket2.tickets_on_order).to contain_exactly(ticket1, ticket2, ticket3)
  end


  it 'has ticket3 getting ticket1 and ticket2 for tickets_on_order' do
    expect(ticket3.tickets_on_order).to contain_exactly(ticket1, ticket2, ticket3)
  end

  it 'has ticket4 getting no related tickets' do
    expect(ticket4.tickets_on_order).to contain_exactly(ticket4)
  end

  
end
