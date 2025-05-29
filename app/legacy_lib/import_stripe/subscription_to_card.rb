# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

class ImportStripe::SubscriptionToCard
  include ActiveModel::AttributeAssignment

  attr_accessor :nonprofit, :row, :copy_row

  def initialize(attr = {})
    assign_attributes(attr)
  end

  def amount
    (row[:amount] * 100).to_i
  end

  def current_period_ends
    Format::Date.parse(row[:current_period_end_utc])
  end

  def customer_name
    row[:customer_description]
  end

  def customer_email
    row[:customer_email]
  end

  def product
    row[:product]
  end

  def stripe_card_id
    copy_row[:source_id_new]
  end

  def stripe_customer_id
    row[:customer_id]
  end

  def supporter
    nonprofit.supporters.create_with(name: customer_name).find_or_create_by!(email: customer_email)
  end

  def card
    supporter.cards.create_with(email: customer_email, name: "Imported Card").find_or_create_by!(stripe_customer_id:, stripe_card_id:)
  end

  def token
    InsertSourceToken.create_record(card)
  end

  # the primary method you'll use for inserting a new recurring donation
  def insert_donation
    InsertRecurringDonation.with_stripe(create_hash_for_insert)
  end

  def create_hash_for_insert
    {
      amount: amount.to_s,
      nonprofit_id: nonprofit.id.to_s,
      supporter_id: supporter.id.to_s,
      designation: product,
      token: token.token,
      recurring_donation: {
        start_date: 1.month.from_now.beginning_of_month.to_s,
        paydate: current_period_ends.day.clamp(1, 28).to_s
      }
    }
  end
end
