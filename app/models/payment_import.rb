# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PaymentImport < ApplicationRecord
  # :nonprofit,
  # :user
  has_and_belongs_to_many :donations
  belongs_to :nonprofit
  belongs_to :user
end
