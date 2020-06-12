# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CustomFieldMaster < ApplicationRecord
  # :nonprofit,
  # :nonprofit_id,
  # :name,
  # :deleted,
  # :created_at

  validates :name, presence: true
  validate :no_dupes, on: :create

  belongs_to :nonprofit
  has_many :custom_field_joins, dependent: :destroy

  scope :not_deleted, -> { where(deleted: [nil, false]) }

  def no_dupes
    return self if nonprofit.nil?

    errors.add(:base, 'Duplicate custom field') if nonprofit.custom_field_masters.not_deleted.where(name: name).any?
  end
end
