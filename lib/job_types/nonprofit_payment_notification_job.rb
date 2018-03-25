module JobTypes
 class NonprofitPaymentNotificationJob < EmailJob
   attr_reader :donation_id, :user_id
   def initialize(donation_id, user_id=nil)
     @donation_id = donation_id
     @user_id = user_id
   end

   def perform
     DonationMailer.nonprofit_payment_notification(@donation_id, @user_id).deliver
   end
 end
end