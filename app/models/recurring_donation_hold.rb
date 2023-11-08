class RecurringDonationHold < ApplicationRecord
  # attr_accessible :title, :body
  attr_accessible :end_date
  belongs_to :recurring_donation
end
