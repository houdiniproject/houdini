# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
