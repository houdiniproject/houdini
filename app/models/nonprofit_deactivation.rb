class NonprofitDeactivation < ApplicationRecord
  belongs_to :nonprofit
  attr_accessible :deactivated
end
