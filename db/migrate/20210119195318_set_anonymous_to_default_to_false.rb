# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SetAnonymousToDefaultToFalse < ActiveRecord::Migration[6.1]
  def change
    change_column_default :supporters, :anonymous, from: nil, to: false
    change_column_null :supporters, :anonymous, false, false
  end
end
