# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Ticket, type: :model do
  it {
    is_expected.to belong_to(:ticket_purchase)
  }

  let(:payment1) { force_create(:payment) }
  let(:payment2) { force_create(:payment) }
  let(:ticket1) { force_create(:ticket, payment: payment1) }
  let(:ticket2) { force_create(:ticket, payment: payment1) }
  let(:ticket3) { force_create(:ticket, payment: payment1) }
  let(:ticket4) { force_create(:ticket, payment: payment2) }

  before(:each) do
    ticket1
    ticket2
    ticket3
    ticket4
  end

  it "has ticket1 getting ticket2 and ticket3 for related_tickets" do
    expect(ticket1.related_tickets).to contain_exactly(ticket2, ticket3)
  end

  it "has ticket2 getting ticket1 and ticket3 for related_tickets" do
    expect(ticket2.related_tickets).to contain_exactly(ticket1, ticket3)
  end

  it "has ticket3 getting ticket1 and ticket2 for related_tickets" do
    expect(ticket3.related_tickets).to contain_exactly(ticket1, ticket2)
  end

  it "has ticket4 getting no related tickets" do
    expect(ticket4.related_tickets).to be_empty
  end

  it "has a valid ticket_base factory" do
    ticket = build(:ticket_base)

    ticket.valid?
    expect(ticket.errors).to be_empty
  end
end
