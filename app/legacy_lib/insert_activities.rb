# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "qx"
require "active_support/core_ext"
require "format/currency"
require "format/date"

module InsertActivities
  def self.insert_cols
    ["action_type", "public", "created_at", "updated_at", "supporter_id", "attachment_type", "attachment_id", "nonprofit_id", "date", "json_data", "kind"]
  end

  # These line up with the above columns
  def self.defaults
    now = Time.current
    ["'created' AS action_type", "'f' AS public", "'#{now}'", "'#{now}'"]
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
      .left_outer_join("payments AS payment", "payment.id=tickets.payment_id")
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

  def self.for_supporter_notes(ids)
    insert_supporter_notes_expr
      .and_where("supporter_notes.id IN ($ids)", ids: ids)
      .execute
  end

  def self.insert_supporter_notes_expr
    Qx.insert_into(:activities, insert_cols.concat(["user_id"]))
      .select(defaults.concat([
        "supporter_notes.supporter_id",
        "'SupporterEmail' AS attachment_type",
        "supporter_notes.id AS attachment_id",
        "supporters.nonprofit_id",
        "supporter_notes.created_at AS date",
        "json_build_object('content', supporter_notes.content, 'user_email', users.email)",
        "'SupporterNote' AS kind",
        "users.id AS user_id"
      ]))
      .from(:supporter_notes)
      .join("supporters", "supporters.id=supporter_notes.supporter_id")
      .add_left_join(:users, "users.id=supporter_notes.user_id")
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
