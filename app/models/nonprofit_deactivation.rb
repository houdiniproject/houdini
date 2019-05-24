class NonprofitDeactivation < ActiveRecord::Base
  belongs_to :nonprofit
  attr_accessible :deactivated
end
