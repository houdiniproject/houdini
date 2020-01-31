class NonprofitVerificationProcessStatus < ActiveRecord::Base
  attr_accessible :started_at, :last_changed_from_pending_to_more_needed, :stripe_account_id

  belongs_to :stripe_account, foreign_key: :stripe_account_id

end
