# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SupporterNote < ApplicationRecord
  attr_accessible \
    :content,
    :supporter_id, :supporter,
    :user

  belongs_to :supporter
  has_many :activities, as: :attachment, dependent: :destroy
  belongs_to :user

  validates :content, length: {minimum: 1}
  validates :supporter, presence: true

  after_create :create_activity

  concerning :ETapImport do
    included do
      has_many :journal_entries_to_items, as: :item
    end
  end

  private

  def create_activity
    InsertActivities.for_supporter_notes([id])
  end
end
