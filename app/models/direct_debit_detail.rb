# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DirectDebitDetail < ApplicationRecord
  attr_accessible :iban, :account_holder_name, :bic, :supporter_id, :holder

  has_many :donations
  has_many :charges
  belongs_to :holder, class_name: Supporter
end
