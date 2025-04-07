# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class OffsitePayment < ApplicationRecord
  # :gross_amount,
  # :kind,
  # :date,
  # :check_number
  belongs_to :payment, dependent: :destroy
  belongs_to :donation
  belongs_to :nonprofit
  belongs_to :supporter
end
