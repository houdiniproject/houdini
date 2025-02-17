# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TagDefinition < ApplicationRecord
  include Model::Eventable
  include Model::Jbuilder

  # TODO replace with Discard gem
  define_model_callbacks :discard

  after_discard :publish_deleted

  # :nonprofit, :nonprofit_id,
  # :name,
  # :deleted,
  # :created_at

  validates :name, presence: true
  validate :no_dupes, on: :create

  after_create_commit :publish_create
  belongs_to :nonprofit
  has_many :tag_joins, dependent: :destroy
  has_one :email_list

  scope :not_deleted, -> { where(deleted: [nil, false]) }

  def no_dupes
    return self if nonprofit.nil?

    errors.add(:base, "Duplicate tag") if nonprofit.tag_definitions.not_deleted.where(name: name).any?
  end

  # TODO replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :name, :deleted)
      json.object "tag_definition"

      json.add_builder_expansion :nonprofit
    end
  end

  private

  def publish_create
    Houdini.event_publisher.announce(:tag_definition_created, to_event("tag_definition.created", :nonprofit).attributes!)
  end

  def publish_deleted
    Houdini.event_publisher.announce(:tag_definition_deleted, to_event("tag_definition.deleted", :nonprofit).attributes!)
  end
end
