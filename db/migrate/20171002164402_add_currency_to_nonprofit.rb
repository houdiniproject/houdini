# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddCurrencyToNonprofit < ActiveRecord::Migration[4.2]
  def change
    add_column :nonprofits, :currency, :string, default: Settings.intntl.currencies[0]
  end
end
