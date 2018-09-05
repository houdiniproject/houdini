class AddressToTransactionRelation < ActiveRecord::Base
  attr_accessible :address, :address_id, :transactionable_id, :transactionable_type
  belongs_to :address
  belongs_to :transactionable, polymorphic: true
  validates :address_id, :transactionable_id, :transactionable_type, presence: true
end
