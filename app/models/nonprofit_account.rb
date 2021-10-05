# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class NonprofitAccount < ApplicationRecord
  # :stripe_account_id, #str
  # :nonprofit, :nonprofit_id #int

  belongs_to :nonprofit

  validates :nonprofit, presence: true
  validates :stripe_account_id, presence: true
end
