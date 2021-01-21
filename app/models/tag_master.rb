# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class TagMaster < ApplicationRecord
  include ObjectEvent::ModelExtensions
  object_eventable :tagmstr
  # TODO replace with Discard gem
  define_model_callbacks :discard

  after_discard :publish_delete

  # :nonprofit, :nonprofit_id,
  # :name,
  # :deleted,
  # :created_at

  validates :name, presence: true
  validate :no_dupes, on: :create

  after_create :publish_create
  belongs_to :nonprofit
  has_many :tag_joins, dependent: :destroy
  has_one :email_list

  scope :not_deleted, -> { where(deleted: [nil, false]) }

  def no_dupes
    return self if nonprofit.nil?

    errors.add(:base, 'Duplicate tag') if nonprofit.tag_masters.not_deleted.where(name: name).any?
  end


  # TODO replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end
  
  def to_builder(*expand)
    Jbuilder.new do |tag|
      tag.(self, :id, :name, :deleted)
      tag.object 'tag_master'
      if expand.include? :nonprofit && nonprofit
        tag.nonprofit nonprofit.to_builder
      else
        tag.nonprofit nonprofit && nonprofit.id
      end
    end
  end


private
  def publish_create
    Houdini.event_publisher.announce(:tag_master_created, to_event('tag_master.created', :nonprofit).attributes!)
  end

  def publish_delete
    Houdini.event_publisher.announce(:tag_master_deleted, to_event('tag_master.deleted', :nonprofit).attributes!)
  end
end
