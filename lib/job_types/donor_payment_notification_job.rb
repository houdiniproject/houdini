module JobTypes
 class DonorPaymentNotificationJob < EmailJob
   attr_reader :donation_id
   def initialize(donation_id, locale=I18n.locale)
     @donation_id = donation_id
     @locale = locale
   end

   def perform
     DonationMailer.donor_payment_notification(@donation_id, @locale).deliver
   end
 end
end