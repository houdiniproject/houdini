class DisputePaymentBackup < ApplicationRecord
  belongs_to :dispute
  belongs_to :payment
  attr_accessible :dispute, :payment_id
end
