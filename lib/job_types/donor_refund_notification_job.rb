module JobTypes
 class DonorRefundNotificationJob < EmailJob
   attr_reader :refund_id
   def initialize(refund_id)
     @refund_id = refund_id
   end

   def perform
     UserMailer.refund_receipt(@refund_id).deliver
   end
 end
end