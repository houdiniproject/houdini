# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MaintainTicketRecords
  # a function for taking every ticket record with a card and creating a token
  # if the event was in the last two weeks
  def self.tokenize_cards_already_on_tickets
    Qx.transaction do
      event_ids = Event.where('end_datetime >= ?', Time.current - 2.weeks).pluck(:id)

      t = Ticket.includes(:card).includes(:event).where('card_id IS NOT NULL and event_id IN (?)', event_ids)
      t.each  do |i|
        token = InsertSourceToken.create_record(i.card, event: i.event)
        i.source_token = token
        i.save!
      end
    end
  end
end
