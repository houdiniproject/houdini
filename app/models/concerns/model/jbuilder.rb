# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::Jbuilder
  extend ActiveSupport::Concern
  class_methods do
    #
    # Builder expansions address a common issue when using Jbuilder for generated JSON for object events work with `#init_builder`
    # In some situations, a model may reference another object but, depending on the situation, may not want to expand that object
    #
    # As an example, consider an hypothetical Supporter class with a reference to a Nonprofit
    #
    # class Supporter < ApplicationRecord
    #		belongs_to :nonprofit
    #   belongs_to :group
    # 	def to_builder(*expand)
    #			 init_builder(*expand) do
    #      # build you JBuilder object
    #			 end
    #   end
    # end
    #
    # When generating the the Jbuilder object, you may want to expand the nonprofit object or in other situations not expand it. To handle this
    # you would need to write the following code:
    # `
    #	if expand.include? :nonprofit
    #		json.nonprofit nonprofit.to_builder.attributes!
    #	else
    #		json.nonprofit nonprofit.to_id
    #	end
    #  `
    # You would have to write the same code for `group`. As your number of expandable attributes increase, your code gets filled with boilerplate code.
    #
    # `add_builder_expansion` addresses this by autocreating this code in to_builder.
    # For example, if you want nonprofit to be expandable as in the nonprofit json attribute, and group into the group json attribute. You only need to write:
    # `add_builder_expansion :nonprofit, :group`
    # You can put as many expandable attributes there as you'd like.
    #
    # On the other hand, let's say you want to make group expandable BUT you want to assign it to the "supporter_group" json attribute. To do that, you
    # pass in the attribute you want to be expandable along with the "json_attribute" method key set to 'supporter_group':
    # `add_builder_expansion :group, json_attribute: 'supporter_group'`
    #
    # For enumerable attributes (like a has_many or an array), there are two ways you may want to include them into your json output. If it's a set of simple values
    # like, an array of strings or numbers, you may want to want to the array output as-is. For example, let's say you have a array of tags which are strings. You may want
    # it to be output like so:
    # ````
    # tags: [ 'founders circle', 'large donor']
    # ```
    # We call these `:flat` enumerable attribtes. Assuming the supporter class before has a tags attribute, you would add the tags builder_expansion using:
    # ```
    # add_builder_expansion :tags, enum_type: :flat
    # ```
    #
    # On the other hand, you may want to have an array of other Jbuilder created objects. Let's say your supporter has many groups. You may want these attributes expanded in
    # one of two ways: expanded or unexpanded.
    #
    # For expanded, you would receive have something like this in your output:
    #
    # {
    #		# ... some other parts of the supporter json
    # 	groups: [{ id: 546, name: 'group name 1'}, {id: 235, name: 'group name 2'}]
    # }
    #
    # However, for unexpanded, you'd just want the ids:
    #
    # {
    #		# ... some other parts of the supporter json
    # 	groups: [546, 235]
    # }
    #
    # For this type of builder expansion, you would use:
    # ```
    # add_builder expansion :groups, enum_type: :expandable
    # ```
    #
    # @param [Symbol] *attributes the attributes you'd like to make expandable. If you want to set options, there should only be a single attribute here.
    # @param  **options options for configuring the builder expansion. The options right now are:
    # - `json_attribute`: the json attribute name in the outputted Jbuilder. Defaults to the attribute name.
    # - `enum_type`: the type of enumerable for the attribute. pass :flat if the enumerable attribute is flat, or :expandable if it's expandable. ANy other value
    # including the default of nil, means the attribute is not enumerable.
    #
    def add_builder_expansion(*attributes, **options)
      builder_expansions.add_builder_expansion(*attributes, **options)
    end

    #
    # A set of all the builder expansions configured for a class
    #
    # @return [Array] the builder expansions
    #
    def builder_expansions
      @builder_expansions ||= BuilderExpansionSet.new
    end

    def init_builder(model, *expand)
      JbuilderWithExpansions.new(model, *expand) do |json|
        json.call(model, :id)
        json.object model.class.name.underscore

        yield(json)
      end
    end

    @minimize_to_object = false

    def to_id_is_object
      @minimize_to_object = true
    end

    def to_id_object?
      @minimize_to_object
    end
  end

  def to_id_object?
    self.class.to_id_object?
  end

  def to_id
    id
  end

  class BuilderExpansionSet < Set
    def add_builder_expansion(*args, **kwargs)
      be = nil
      if args.any? || kwargs.any?
        if args.count == 1 && kwargs.any?
          be = BuilderExpansion.new(key: args[0], **kwargs)
          add(be)
        else
          args.each do |a|
            be = BuilderExpansion.new(key: a)
            add(be)
          end
        end
      else
        raise ArgumentError
      end
    end

    def keys
      map { |i| i.key }
    end

    def get_by_key(key)
      select { |i| i.key == key }.first
    end
  end

  class BuilderExpansion
    include ActiveModel::AttributeAssignment
    attr_accessor :key, :json_attribute, :enum_type

    def initialize(new_attributes)
      assign_attributes(new_attributes)
    end

    def enumerable?
      expandable_enum? || flat_enum?
    end

    def expandable_enum?
      enum_type == :expandable
    end

    def flat_enum?
      enum_type == :flat
    end

    def json_attribute
      (@json_attribute || key).to_s
    end

    def to_id
      ->(model, be = self) {
        value = be.get_attribute_value model
        if be.expandable_enum?
          value&.map do |i|
            id_result = i&.to_id
            if ::Jbuilder === id_result
              id_result.attributes!
            else
              id_result
            end
          end
        elsif be.flat_enum?
          value
        else
          value&.to_id
        end
      }
    end

    def to_builder
      ->(model, be = self) {
        value = be.get_attribute_value model
        if be.expandable_enum?
          value&.map { |i| i&.to_builder&.attributes! }
        elsif be.flat_enum?
          value
        else
          value&.to_builder
        end
      }
    end

    def get_attribute_value(model)
      if model.respond_to? key
        model.send(key)
      else
        raise ActiveModel::MissingAttributeError, "missing attribute: #{key}"
      end
    end
  end

  def init_builder(*expand, &block)
    self.class.init_builder(self, *expand, &block)
  end

  class JbuilderWithExpansions < ::Jbuilder
    attr_reader :model, :expand

    delegate_missing_to :@jbuilder

    def initialize(model, *expand, &block)
      @model = model
      @expand = expand
      super(&block)
    end

    def add_builder_expansion(...)
      builder_expansions = BuilderExpansionSet.new
      builder_expansions.add_builder_expansion(...)
      builder_expansions.keys.each do |k|
        if expand.include? k
          set! builder_expansions.get_by_key(k).json_attribute, builder_expansions.get_by_key(k).to_builder.call(model)
        else
          set! builder_expansions.get_by_key(k).json_attribute, builder_expansions.get_by_key(k).to_id.call(model)
        end
      end
    end
  end
end
