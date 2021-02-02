# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class SupporterNote < ApplicationRecord
  include Model::Eventable
  include Model::Jbuilder

  # :content,
  # :supporter_id, :supporter

  belongs_to :supporter
  has_many :activities, as: :attachment, dependent: :destroy
  belongs_to :user

  validates :content, length: { minimum: 1 }
  validates :supporter_id, presence: true
  # TODO replace with Discard gem

  add_builder_expansion :supporter
  add_builder_expansion :user, 
    to_id: ->(model) { model.user&.id},
    to_expand: ->(model) { model.user&.to_builder}

  add_builder_expansion :nonprofit, 
    to_attrib: -> (model) {model.supporter.nonprofit}

  define_model_callbacks :discard

  after_discard :publish_deleted

  after_create_commit :publish_created
  after_update_commit :publish_updated

  # TODO replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.(self, :id, :deleted, :content)
      json.object 'supporter_note'
    end
  end

  private
  def publish_created
    Houdini.event_publisher.announce(:supporter_note_created, to_event('supporter_note.created', :supporter, :nonprofit, :user).attributes!)
  end

  def publish_updated
    if !deleted
      Houdini.event_publisher.announce(:supporter_note_updated, to_event('supporter_note.updated', :supporter, :nonprofit, :user).attributes!)
    end
  end

  def publish_deleted
    Houdini.event_publisher.announce(:supporter_note_deleted, to_event('supporter_note.deleted', :supporter, :nonprofit, :user).attributes!)
  end
end
