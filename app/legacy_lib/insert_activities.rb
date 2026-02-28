# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module InsertActivities
  def self.insert_cols
    %w[action_type public created_at updated_at supporter_id attachment_type attachment_id nonprofit_id date json_data kind]
  end

  # These line up with the above columns
  def self.defaults
    now = Time.current
    ["'created' AS action_type", "'f' AS public", "'#{now}'", "'#{now}'"]
  end

  def self.create(data)
    Qx.insert_into(:activities)
      .values(data)
      .ts
      .returning("*")
      .execute
  end

  def self.for_recurring_donations(payment_ids)
    insert_recurring_donations_expr
      .and_where("payments.id IN ($ids)", ids: payment_ids)
      .execute
  end

  def self.insert_recurring_donations_expr
    Qx.insert_into(:activities, insert_cols)
      .select(defaults.concat([
        "payments.supporter_id",
        "'Payment' AS attachment_type",
        "payments.id AS attachment_id",
        "payments.nonprofit_id",
        "payments.date",
        "json_build_object('gross_amount', payments.gross_amount, 'start_date', donations.created_at, 'designation', donations.designation, 'dedication', donations.dedication, 'interval', recurring_donations.interval, 'time_unit', recurring_donations.time_unit)",
        "'RecurringDonation' AS kind"
      ]))
      .from(:payments)
      .join(:donations, "donations.id=payments.donation_id")
      .add_join(:recurring_donations, "recurring_donations.donation_id=donations.id")
      .where("payments.kind='RecurringDonation'")
  end

  def self.for_one_time_donations(payment_ids)
    insert_one_time_donations_expr
      .and_where("payments.id IN ($ids)", ids: payment_ids)
      .execute
  end

  def self.insert_one_time_donations_expr
    Qx.insert_into(:activities, insert_cols)
      .select(defaults.concat([
        "payments.supporter_id",
        "'Payment' AS attachment_type",
        "payments.id AS attachment_id",
        "payments.nonprofit_id",
        "payments.date",
        "json_build_object('gross_amount', payments.gross_amount, 'designation', donations.designation, 'dedication', donations.dedication)",
        "'Donation' AS kind"
      ]))
      .from(:payments)
      .join(:donations, "donations.id=payments.donation_id")
      .where("payments.kind='Donation'")
  end

  def self.for_tickets(ticket_ids)
    insert_tickets_expr
      .and_where("tickets.id IN ($ids)", ids: ticket_ids)
      .execute
  end

  def self.insert_tickets_expr
    Qx.insert_into(:activities, insert_cols)
      .select(defaults.concat([
        "tickets.supporter_id",
        "'Ticket' AS attachment_type",
        "tickets.id AS attachment_id",
        "event.nonprofit_id",
        "tickets.created_at AS date",
        "json_build_object('gross_amount', coalesce(payment.gross_amount, 0), 'event_name', event.name, 'event_id', event.id, 'quantity', tickets.quantity)",
        "'Ticket' AS kind"
      ]))
      .from(:tickets)
      .join("payments AS payment", "payment.id=tickets.payment_id")
      .add_join("events AS event", "event.id=tickets.event_id")
  end

  def self.for_refunds(payment_ids)
    insert_refunds_expr
      .and_where("payments.id IN ($ids)", ids: payment_ids)
      .execute
  end

  def self.insert_refunds_expr
    Qx.insert_into(:activities, insert_cols.concat(["user_id"]))
      .select(defaults.concat([
        "payments.supporter_id",
        "'Payment' AS attachment_type",
        "payments.id AS attachment_id",
        "payments.nonprofit_id",
        "payments.date",
        "json_build_object('gross_amount', payments.gross_amount, 'reason', refunds.reason, 'user_email', users.email)",
        "'Refund' AS kind",
        "users.id AS user_id"
      ]))
      .from(:payments)
      .join(:refunds, "refunds.payment_id=payments.id")
      .left_join(:users, "refunds.user_id=users.id")
      .where("payments.kind='Refund'")
  end

  def self.for_disputes(payment_ids)
    insert_disputes_expr
      .and_where("payments.id IN ($ids)", ids: payment_ids)
      .execute
  end

  def self.insert_disputes_expr
    Qx.insert_into(:activities, insert_cols)
      .select(defaults.concat([
        "payments.supporter_id",
        "'Payment' AS attachment_type",
        "payments.id AS attachment_id",
        "payments.nonprofit_id",
        "payments.date",
        "json_build_object('gross_amount', payments.gross_amount, 'reason', disputes.reason, 'original_kind', other_payment.kind, 'original_date', other_payment.date)",
        "'Dispute' AS kind"
      ]))
      .from(:payments)
      .join(:disputes, "disputes.payment_id=payments.id")
      .add_join(:charges, "disputes.charge_id=charges.id")
      .add_join("payments AS other_payment", "other_payment.id=charges.payment_id")
      .where("payments.kind='Dispute'")
  end

  def self.for_supporter_notes(notes)
    notes.map do |note|
      note.activities.create(supporter: note.supporter,
        nonprofit: note.supporter.nonprofit,
        date: note.created_at,
        kind: "SupporterNote",
        user: note.user,
        json_data: {
          content: note.content,
          user_email: note.user&.email
        })
    end
  end

  def self.for_offsite_donations(payment_ids)
    insert_offsite_donations_expr
      .and_where("payments.id IN ($ids)", ids: payment_ids)
      .execute
  end

  def self.insert_offsite_donations_expr
    Qx.insert_into(:activities, insert_cols.concat(["user_id"]))
      .select(defaults.concat([
        "payments.supporter_id",
        "'Payment' AS attachment_type",
        "payments.id AS attachment_id",
        "payments.nonprofit_id",
        "payments.date",
        "json_build_object('gross_amount', payments.gross_amount, 'designation', donations.designation, 'user_email', users.email)",
        "'OffsitePayment' AS kind",
        "users.id AS user_id"
      ]))
      .from(:payments)
      .where("payments.kind = 'OffsitePayment'")
      .join(:offsite_payments, "offsite_payments.payment_id=payments.id")
      .add_join(:donations, "payments.donation_id=donations.id")
      .add_left_join(:users, "users.id=offsite_payments.user_id")
  end
end
