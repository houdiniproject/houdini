class TicketOrder < ActiveRecord::Base
  belongs_to :supporter
  has_one :address, as: :transactionable, class_name: 'TransactionAddress'
  has_many :tickets
end
