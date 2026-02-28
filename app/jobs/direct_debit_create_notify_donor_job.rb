class DirectDebitCreateNotifyDonorJob < EmailJob
  def perform(donation_id, locale)
    DonationMailer.donor_direct_debit_notification(donation_id, locale).deliver_now
  end
end
