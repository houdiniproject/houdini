# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SourceToken < ApplicationRecord
  self.primary_key = :token

  attr_accessible :expiration, :token, :max_uses, :total_uses
  belongs_to :tokenizable, polymorphic: true
  belongs_to :event

  scope :expired, -> { where("max_uses <= total_uses OR expiration < ?", Time.now) }
  scope :unexpired, -> { where(" NOT (max_uses <= total_uses OR expiration < ?)", Time.now) }

  scope :last_used_more_than_a_month_ago, -> { where("source_tokens.updated_at < ? ", 1.month.ago) }

  def expired?
    max_uses <= total_uses || source_token.expiration < Time.now
  end

  def unexpired?
    !expired?
  end
end
