class PaymentDupeStatus < ActiveRecord::Base
    belongs_to :payment
end
