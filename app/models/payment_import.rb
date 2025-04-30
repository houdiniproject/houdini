# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PaymentImport < ApplicationRecord
  attr_accessible :nonprofit, :user
  has_and_belongs_to_many :donations, join_table: "donations_payment_imports"
  belongs_to :nonprofit
  belongs_to :user
end
