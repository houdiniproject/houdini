# frozen_string_literal: true

class AddIndexesToSupporterNotes < ActiveRecord::Migration[4.2]
  def change
    add_index :supporter_notes, :supporter_id, order: { supporter_id: :asc }
  end
end
