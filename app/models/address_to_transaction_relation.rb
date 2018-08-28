class AddressToTransactionRelation < ActiveRecord::Base
  attr_accessible :address, :address_id
  belongs_to :address
  belongs_to :transactionable, polymorphic: true
end
