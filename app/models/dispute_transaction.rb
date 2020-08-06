class DisputeTransaction < ActiveRecord::Base
  belongs_to :dispute
  belongs_to :payment
  attr_accessible :gross_amount, :disbursed, :payment

  def gross_amount=(gross_amount)
    write_attribute(:gross_amount, gross_amount)
    calculate_net
  end

  def fee_total=(fee_total)
    write_attribute(:fee_total, fee_total)
    calculate_net
  end

  private
  def calculate_net
    self.net_amount = gross_amount + fee_total
  end
end
