# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class SupporterEmail < ApplicationRecord
  # :to,
  # :from,
  # :subject,
  # :body,
  # :recipient_count,
  # :supporter_id, :supporter,
  # :nonprofit_id,
  # :gmail_thread_id

  belongs_to :supporter
  validates_presence_of :nonprofit_id
  has_many :activities, as: :attachment, dependent: :destroy
end
