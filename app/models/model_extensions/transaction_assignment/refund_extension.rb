# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module ModelExtensions::TransactionAssignment::RefundExtension
  def trx
    proxy_association.owner
  end

  def assignments
    proxy_association.owner.transaction_assignments
  end

  # Handle a completed refund from a legacy Refund object
  def process_refund(refund)
    donation = assignments.select { |i| i.assignable.is_a? ModernDonation }.first.assignable
    donation.amount = trx.amount
    donation.save!
  end
end
