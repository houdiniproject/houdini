# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class SetSupporterNoteDeletedDefaultToFalse < ActiveRecord::Migration[6.1]
  def change
    change_column_default :supporter_notes, :deleted, from: nil, to: false
    change_column_null :supporter_notes, :deleted, false
  end
end
