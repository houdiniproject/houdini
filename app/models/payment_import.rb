class PaymentImport < ActiveRecord::Base
  attr_accessible :nonprofit, :user
  has_and_belongs_to_many :donations
  belongs_to :nonprofit
  belongs_to :user
end
