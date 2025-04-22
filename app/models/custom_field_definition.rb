# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CustomFieldDefinition < ApplicationRecord
  include Model::Eventable
  include Model::Jbuilder

  validates :name, presence: true
  validate :no_dupes, on: :create

  belongs_to :nonprofit
  has_many :custom_field_joins, dependent: :destroy

  scope :not_deleted, -> { where(deleted: false) }

  after_create_commit :publish_created

  # TODO: replace with Discard gem
  define_model_callbacks :discard

  after_discard :publish_delete

  # TODO: replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end

  def no_dupes
    return self if nonprofit.nil?

    errors.add(:base, "Duplicate custom field") if nonprofit.custom_field_definitions.not_deleted.where(name: name).any?
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :name, :deleted)
      json.object "custom_field_definition"

      json.add_builder_expansion :nonprofit
    end
  end

  private

  def publish_created
    Houdini.event_publisher.announce(:custom_field_definition_created,
      to_event("custom_field_definition.created", :nonprofit).attributes!)
  end

  def publish_delete
    Houdini.event_publisher.announce(:custom_field_definition_deleted,
      to_event("custom_field_definition.deleted", :nonprofit).attributes!)
  end
end
