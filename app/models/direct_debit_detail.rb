class DirectDebitDetail < ActiveRecord::Base
  attr_accessible :iban, :account_holder_name, :bic, :supporter_id, :holder

  has_many :donations
  has_many :charges
  belongs_to :holder, class_name: Supporter
end
