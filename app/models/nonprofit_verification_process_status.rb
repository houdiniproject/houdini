class NonprofitVerificationProcessStatus < ActiveRecord::Base
  attr_accessible :started_at

  belongs_to :nonprofit

end
