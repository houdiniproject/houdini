# @license License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# An ObjectEvent represents a change that was made to an Houdini object. For example, when a supporter
# is created a "supporter.created" object event is created. Object event names are:
#
# 1. lower case and snake case with no spaces
# 2. consist of the Houdini object type name (usually, but not always, the class name snake-cased) and
# and the event name, both snake_cased, seperated by a period
#
# How to set up object events for a class.
#
# Setting up object events is pretty straightforward. You have to do the following:
#
## Make sure `#setup_houid` is run on your class.
# TIP: have your model inherit from `ApplicationRecord` so `#setup_houid` is available.
#
# ```ruby
# in app/models/family_object.rb
# class FamilyObject < ApplicationRecord
#   setup_houid :familyobj, :houid
# end
# ```
#
## Add a method on your class for the event and which creates a new ObjectEvent
#
# ```ruby
# in app/models/family_object.rb
# class FamilyObject < ApplicationRecord
#   setup_houid :familyobj, :houid
#
#   def publish_created # recommended that the method be `publish_<name_of_event_in_snake_case>`
#     ObjectEvent.create(event_entity: self, event_type: 'family_object.created')
#   end
# end
# ```
#
## Add a jbuilder template for generating the ObjectEvent JSON
# Place a jbuilder partial template at `app/views/api_new/<class name, snakecased>/object_events/_base.json`, which calls the general Jbuilder partial for the class
# and sets what attributes should be expanded.
#
# ```ruby
# in app/views/api_new/class name, snakecased/object_events/_base.json
#
# json.partial! event_entity, # the object is always passed in as `event_entity`
#   as: :family_object, # this is the parameter that your class' partial uses
#   __expand: build_json_expansion_path_tree('parent') # this tells us what parts of the object should be expanded using JSON SPaths
#
# ```
#
# @see Controllers::ApiNew::JbuilderExpansions
#
# @!attribute [r] event_type
#   @return [String] the type of the ObjectEvent. If a supporter was created, this would be `supporter.created`
# @!attribute [r] event_entity_houid
#   @return [String] the houid of the object that the event occurred on. Automatically set at creation.
# @!attribute [r] created
#   @return [Time] the moment in UTC that the object event was created. Automatically set at creation.
# @!attribute [r] object_json
#   @return [Hash] the json representing the event. Automatically set at creation.
class ObjectEvent < ApplicationRecord
  include Model::CreatedTimeable
  setup_houid :evt, :houid

  # @option attributes [#to_houid] :event_entity the object that had an event
  # @option attributes [String] :event_type the name of the event that occurred on an object
  def initialize(attributes = nil, options = {})
    super
  end
  # Event entity is the Houdini object associated with the object event
  belongs_to :event_entity, polymorphic: true
  # the nonprofit the event_entity belongs to
  belongs_to :nonprofit

  # methods that relate to querying for a nonprofit's (ObjectEvent)s
  concerning :Query do
    class_methods do
      # Queries the database to find every ObjectEvent associated with a particular object
      # @param [string] event_entity_houid the Houid of the object whose object events you want to find
      def event_entity(event_entity_houid)
        where(event_entity_houid: event_entity_houid)
      end

      # Queries the database to find every ObjectEvent of a particular type
      def event_types(types)
        where("event_type IN (?)", types)
      end
    end
  end

  before_validation do
    self[:object_json] = to_object if event_entity
    self[:nonprofit_id] = event_entity&.nonprofit&.id if event_entity.respond_to? :nonprofit
    self[:event_entity_houid] = event_entity&.houid
  end

  private

  #
  # Generates the JSON representing the [ObjectEvent]
  # @return [Object] the JSON representing the ObjectEvent
  def to_object
    JSON.parse(ApiNew::ObjectEventsController.render("api_new/object_events/generate",
      assigns: {
        object_event: self,
        event_entity: event_entity,
        partial_path: "api_new/#{event_entity.to_partial_path.split("/").delete_at(0)}/object_events/base"
      }))
  end
end
