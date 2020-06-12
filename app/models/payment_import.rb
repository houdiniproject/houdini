# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class PaymentImport < ApplicationRecord
  # :nonprofit,
  # :user
  has_and_belongs_to_many :donations
  belongs_to :nonprofit
  belongs_to :user
end
