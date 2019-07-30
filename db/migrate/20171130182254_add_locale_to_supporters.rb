# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddLocaleToSupporters < ActiveRecord::Migration
  def change
    add_column :supporters, :locale, :string
  end
end
