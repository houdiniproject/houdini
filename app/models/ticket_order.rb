class TicketOrder < ActiveRecord::Base
  attr_accessible :supporter
  belongs_to :supporter
  has_one :address, as: :transactionable, class_name: 'TransactionAddress'
  has_many :tickets
end
