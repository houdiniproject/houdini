# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class DirectDebitDetail < ApplicationRecord
  # :iban,
  # :account_holder_name,
  # :bic,
  # :supporter_id,
  # :holder

  has_many :donations
  has_many :charges
  belongs_to :holder, class_name: "Supporter"
end
