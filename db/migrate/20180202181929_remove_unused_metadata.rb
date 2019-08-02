# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RemoveUnusedMetadata < ActiveRecord::Migration
  TABLES = %i[
    campaign_gift_options
    campaign_gifts
    campaigns
    cards
    charges
    custom_field_masters
    custom_field_joins
    disputes
    donations
    events
    imports
    nonprofits
    offsite_payments
    payments
    payment_payouts
    payouts
    profiles
    recurring_donations
    refunds
    roles
    supporter_emails
    supporter_notes
    supporters
    tag_joins
    tag_masters
    ticket_levels
    tickets
    users
  ].freeze
  FIELDS = %i[id metadata].freeze

  def up
    TABLES.each do |table|
      remove_column table, :metadata
    end
  end

  def down
    TABLES.each  do |table|
      add_column table, :metadata, :text
    end
  end
end
