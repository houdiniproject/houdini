class NonprofitVerificationProcessStatus < ApplicationRecord
  attr_accessible :started_at, :stripe_account_id

  belongs_to :stripe_account, primary_key: :stripe_account_id
end
