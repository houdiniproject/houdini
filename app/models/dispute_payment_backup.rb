class DisputePaymentBackup < ActiveRecord::Base
  belongs_to :dispute
  attr_accessible :dispute, :payment_id
end
