# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SetDefaultsOnTicketBooleans < ActiveRecord::Migration[6.1]
  def change
    change_column_default :tickets, :checked_in, from: nil, to: false
    change_column_null :tickets, :checked_in, false

    change_column_default :tickets, :deleted, from: nil, to: false
    change_column_null :tickets, :deleted, false
  end
end
