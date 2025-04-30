# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ImportOnecauseEventDonations
  #
  # Import from a Onecause Event Donation export
  #
  # @param [Event] event the event the donations happened at
  # @param [TicketLevel] event the ticket level used for users who don't have a ticket
  # @param [Array<Hash>] csv csv import file
  #
  def self.import(event, ticket_level, csv)
    Qx.transaction do
      np = event.nonprofit

      bidder_groups = csv.group_by { |a| a["Bidder #"] }
      bidder_groups.keys.each do |i|
        payment_row, non_payment = bidder_groups[i].partition { |row| row["Action"] == "Payment" }

        payment_row = payment_row.select { |i| i["Payment Status"] == "Approved" }.first

        supporter_info_row = payment_row || non_payment.first

        supporter_name = supporter_info_row["First Name"] + " " + supporter_info_row["Last Name"]
        supporter = winnow_to_supporter(event, np, supporter_name, supporter_info_row["Email"])

        supporter ||= Supporter.find(InsertSupporter.create_or_update(np.id, {
          name: supporter_name,
          email: supporter_info_row["Email"],
          city: supporter_info_row["City"],
          state_code: supporter_info_row["State"],
          zip_code: supporter_info_row["Zip"],
          phone: supporter_info_row["Phone #"],
          organization: supporter_info_row["Company"]
        })["id"])

        ticket = winnow_tickets(event, supporter)

        ticket = if ticket
          ticket.attributes
        else
          # we create new ticket
          InsertTickets.create({
            tickets: [{quantity: 1, ticket_level_id: ticket_level.id}],
            event_id: event.id,
            nonprofit_id: np.id,
            supporter_id: supporter.id
          }, true)["tickets"][0]
        end

        if payment_row
          # do offsite donation for the supporter
          InsertDonation.offsite({
            amount: payment_row["Payment Amount"].to_i * 100,
            nonprofit_id: np.id,
            supporter_id: supporter.id,
            event_id: event.id,
            offsite_payment: {}
          }.with_indifferent_access)
        end

        notes = create_notes(payment_row, non_payment)

        notes = ticket["note"] ? ticket["note"] + '\n' + notes : notes
        # edit the ticket.notes for the supporter
        UpdateTickets.update({event_id: event.id, ticket_id: ticket["id"], note: notes})
      end
    end
  end

  def self.winnow_to_supporter(event, np, name, email = nil)
    possible_supporters = if email
      np.supporters.not_deleted.where("email = ? ", email)
    else
      np.supporters.not_deleted.where("name = ?", name)
    end

    if possible_supporters.none?
      return nil
    elsif possible_supporters.one?
      return possible_supporters.first
    end

    tickets_for_supporters = event.tickets.where("supporter_id IN (?)", possible_supporters.map { |i| i.id })

    if tickets_for_supporters.none?
      possible_supporters.first
    elsif tickets_for_supporters.one?
      tickets_for_supporters.first.supporter
    else
      Supporter.find(tickets_for_supporters.map { |i| i.supporter_id }.uniq.first)
    end
  end

  def self.winnow_tickets(event, supporter)
    event.tickets.where("supporter_id = ?", supporter.id).first
  end

  def self.create_notes(p_row, np_rows)
    bidder_num = np_rows.first["Bidder #"]
    table_num = np_rows.first["Table #"]
    user_def_1 = np_rows.first["User Defined 1"]
    user_def_2 = np_rows.first["User Defined 2"]
    notes = np_rows.first["Notes"]

    output = []

    output.push("Bidder #: #{bidder_num}") if bidder_num
    output.push("Table #: #{table_num}") if table_num
    output.push("User Defined 1: #{user_def_1}") if user_def_1
    output.push("User Defined 2: #{user_def_2}") if user_def_2

    output.push("Payments:")

    np_rows.each do |row|
      row_str = "Item ##{row["Item #"]}, #{row["Item Name"]} -- $#{row["Amount"]}, Value: $#{row["Value"] || 0}, Item/Charge Type: #{row["Item/Charge Type"]}"
      output.push("- #{row_str}")
    end

    output.push("Notes: #{notes}") if notes

    output.join("\n")
  end
end
