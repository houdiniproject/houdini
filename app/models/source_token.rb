class SourceToken < ActiveRecord::Base
  self.primary_key = :token
  attr_accessible :expiration, :token, :max_uses, :total_uses
  belongs_to :tokenizable, :polymorphic => true
  belongs_to :event
end
