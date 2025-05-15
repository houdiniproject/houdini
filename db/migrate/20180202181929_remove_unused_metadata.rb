# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RemoveUnusedMetadata < ActiveRecord::Migration
  TABLES = [
    :campaign_gift_options,
    :campaign_gifts,
    :campaigns,
    :cards,
    :charges,
    :custom_field_masters,
    :custom_field_joins,
    :disputes,
    :donations,
    :events,
    :imports,
    :nonprofits,
    :offsite_payments,
    :payments,
    :payment_payouts,
    :payouts,
    :profiles,
    :recurring_donations,
    :refunds,
    :roles,
    :supporter_emails,
    :supporter_notes,
    :supporters,
    :tag_joins,
    :tag_masters,
    :ticket_levels,
    :tickets,
    :users
  ]
  FIELDS = [:id, :metadata]

  def up
    TABLES.each { |table|
      remove_column table, :metadata
    }
  end

  def down
    TABLES.each { |table|
      add_column table, :metadata, :text
    }
  end
end
