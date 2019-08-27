# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe QueryTicketLevels do
  include_context :shared_donation_charge_context
  describe '.gross_amount_from_tickets' do
    let(:bp) {force_create(:billing_plan, percentage_fee: 0.05)}
    let(:bs) {force_create(:billing_subscription, nonprofit:nonprofit, billing_plan: bp)}

    it 'handles free tickets only properly' do
      bs
      result = QueryTicketLevels.gross_amount_from_tickets(['ticket_level_id' => free_ticket_level.id, 'quantity'=> 5], nil, nil, nonprofit.id)
      expect(result).to eq 0
    end

    it 'handles nonfree tickets only properly' do
      bs
      result = QueryTicketLevels.gross_amount_from_tickets(['ticket_level_id' => ticket_level.id, 'quantity'=> 5], nil, false, nonprofit.id)
      expect(result).to eq 2000
    end

    it 'handles mix of tickets properly' do
      bs
      result = QueryTicketLevels.gross_amount_from_tickets(
          [{'ticket_level_id' => ticket_level.id, 'quantity'=> 5},
           {'ticket_level_id' => ticket_level2.id, 'quantity'=> 2},
           {'ticket_level_id' => free_ticket_level.id, 'quantity'=> 4000}], nil, true, nonprofit.id)
      expect(result).to eq 3266
    end

    it 'handles mix of tickets properly with discount code properly' do
      bs
      result = QueryTicketLevels.gross_amount_from_tickets(
          [{'ticket_level_id' => ticket_level.id, 'quantity'=> 5},
           {'ticket_level_id' => ticket_level2.id, 'quantity'=> 2},
           {'ticket_level_id' => free_ticket_level.id, 'quantity'=> 4000}], event_discount.id, false, nonprofit.id)
      expect(result).to eq 2400
    end

    it 'handles mix of tickets properly with discount code and fee covered properly' do
      bs
      result = QueryTicketLevels.gross_amount_from_tickets(
          [{'ticket_level_id' => ticket_level.id, 'quantity'=> 5},
           {'ticket_level_id' => ticket_level2.id, 'quantity'=> 2},
           {'ticket_level_id' => free_ticket_level.id, 'quantity'=> 4000}], event_discount.id, true, nonprofit.id)
      expect(result).to eq 2619
    end
  end

  describe '.verify_tickets_available' do
    let(:ticket_level_1){ force_create(:ticket_level, limit: 3)}
    let(:ticket_level_2) { force_create(:ticket_level, limit: 2)}
    let(:tickets) {[
        force_create(:ticket, ticket_level: ticket_level_1, quantity: 1),
        force_create(:ticket, ticket_level: ticket_level_1, quantity: 1)
    ]}

    it 'fails when ticket level is too many' do
      expect { QueryTicketLevels.verify_tickets_available([
          {ticket_level_id: ticket_level_1.id, quantity: 50},
          {ticket_level_id: ticket_level_2.id, quantity: 1}
                                                          ])}.to raise_error(NotEnoughQuantityError)
      expect { QueryTicketLevels.verify_tickets_available([

                          {ticket_level_id: ticket_level_2.id, quantity: 3}
                                                          ])}.to raise_error(NotEnoughQuantityError)
    end

    it 'allows when a full item is at 0 and other is acceptable' do
      expect { QueryTicketLevels.verify_tickets_available([
        {ticket_level_id: ticket_level_1.id, quantity: 0},
        {ticket_level_id: ticket_level_2.id, quantity: 2}
                                                          ])}.to_not raise_error
    end

    it 'allows when only acceptable are passed ' do
      expect { QueryTicketLevels.verify_tickets_available([
                                                              {ticket_level_id: ticket_level_2.id, quantity: 2}
                                                          ])}.to_not raise_error
    end
  end

end