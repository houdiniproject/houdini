class AddIndexesToSupporterNotes < ActiveRecord::Migration
  def change
    add_index :supporter_notes, :supporter_id, order: {supporter_id: :asc}
  end
end
