# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SetTicketLevelDeletedToDefaultFalse < ActiveRecord::Migration[6.1]
  def change
    change_column_default :ticket_levels, :deleted, from: nil, to: false
    change_column_null :ticket_levels, :deleted, false
  end
end
