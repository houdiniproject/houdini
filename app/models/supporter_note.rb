# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class SupporterNote < ApplicationRecord
  # :content,
  # :supporter_id, :supporter

  belongs_to :supporter
  has_many :activities, as: :attachment, dependent: :destroy

  validates :content, length: { minimum: 1 }
  validates :supporter_id, presence: true


  
end
