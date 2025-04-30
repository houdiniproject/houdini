# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

#
# This concern simplifies creating JBuilder objects.
#
## The format for child objects in Houdini API
#
# Child objects for attributes for the Houdini API follow a format based upon the Stripe API
# When a child is not expanded it will consist only of the Houid
# For example consider in the following object, child is not expanded:
# ```json
# {
# 	child: "chd_21n45ho...",
# 	id: "familyobj_4532154ni"
# }
# ```
#
# However when a child is expanded it will look like this:
#
# ```json
# {
#   child: {
# 			id: "chd_21n45ho...",
# 			additional_attribute: 1,
#       parent: "prt_352159",
#       subchildren: ["subchd_235n158...", "subchd_203213598..."]
# 	},
# 	id: "familyobj_4532154ni"
# }
# ```
#
### JSON Simplified Path (SPath)
# a JSON Simplified Path (SPath) is a bit like dot object notation for JSON objects. For example
# If you wanted to reference the child attribute above, you would use the very simple spath of
# `child`
#
# If you wanted to reference the child's id attribute, you would use `child.id`
#
# One characteristic of SPaths is how they handle arrays. If an spath references an array, it's
# actually referencing every item in the array. This will matter later in this code.
#
# ##Combining SPaths and expansion
# Now that have SPaths you may be wondering how this relates to expandable attributes. Based upon some input,
# we may want decided at runtime whether expand an attribute when rendering Jbuilder templates SPaths allow us to define which items are expanded. To do so,
# we go to our Controller action and provide the SPaths of which attributes we want expanded in the outputted object. We do this by passing the
# the SPaths to the `set_json_expansion_paths` method. So, if we want to expand the `child` from above, we would call:
# `set_json_expansion_paths('child')`
#  ```json
# {
#   child: {
# 		id: "chd_21n45ho...",
# 		additional_attribute: 1,
# 		parent: {
# 			id:	"prt_352159"
# 			some_other_attribute: "attrib to remember"
# 		},
# 		subchildren: ["subchd_235n158...", "subchd_203213598..."]
# 	},
# 	id: "familyobj_4532154ni"
# }
# ```
#
# What if we want to expand the parent attribute inside child? We can pass the SPath as follows:`set_json_expansion_paths('child.parent')`. And we get the following:
#
# Notice that we
# don't have to pass child separately. Our expansions know to expand everything back to the root of our Jbuilder value. Your could pass `set_json_expansion_paths('child', 'child.parent')`
#
# What happens for arrays? We can pass the SPath for subchildren using the same notation `set_json_expansion_paths('child.subchildren')`:
#
# ```json
# {
#   child: {
# 		id: "chd_21n45ho...",
# 		additional_attribute: 1,
# 		parent: "prt_352159",
# 		subchildren: [
# 			{
# 					id: "subchd_235n158...",
# 				value: 22942190
# 				},
# 			{
# 				id:  "subchd_203213598...",
# 				value: 312539
# 			}
# 		]
# 	},
# 	id: "familyobj_4532154ni"
# }
# ```
#
# ##Expansion and partials
# You may be wondering how we know what to generate when we ask for an object to be expanded. We use a feature of JBuidler
# where, which selects the partial based upon the class of the object passed to `partial!`. For example,
# if you call `json.partial! object` and object is of type Parent, Jbuilder knows that you want to use the partial at `app/views/parents/_parent.json.jbuilder`.
#
### How to use this all in practice on a controller action
# Using this in practice requires a few steps but is honestly pretty straightforward.
#
#### 1. Make sure there is a #to_houid method on the object
# Remember, for an object to be shrunk, we need to be able to output the value #to_houid. So we need that for any object which could be expanded.
#
#### 2. Make sure to call `#set_json_expansion_paths` in your action with the SPaths you want to expand.
#
# In your controller action, you need to set which SPaths you want to expand. You can set these based upon parameters passed in (you may want to limit the depth however)
# or simply have a default value.
#
# ```ruby
# in `app/controllers/family_objects_controller.rb`
# class FamilyObjectsController < ApplicationController
# 	include Controllers::ApiNew::JbuilderExpansions
#
# 	def show
# 		set_json_expansion_paths('child') # we just want to expand the child attribute
# 		@family_object = FamilyObject.find(.........) # assume you get the family object you want here
# 	end
# end
# ````
#
#### 3. In your JBuilder view template for the show action make sure to add `__expand: @expand` to the end of your render partial call
#
# ```ruby
# in `app/views/family_objects/show.json.jbuilder`
# json.partial! @family_object, as: :family_object, __expand: @__expand
# ```
#
#### 4. Starting at the partial called in your show template, add `#handle_expansion` and `#handle_array_expansion` calls
#
# ```ruby
# in `app/views/family_objects/_family_object.json.jbuilder`
#
# json.id family_object.to_houid
#
# handle_expansion(:child, family_object, {json: json, __expand: __expand}) # make sure json and __expand are there!
# ```
#
#### 5. Continue adding expansion calls in any partials referred to by the initial partial or any partials it references recursively
#
# ```ruby
# in `app/views/children/_child.json.jbuilder`
# json.id child.to_houid
#
# json.(child, :additional_attribute)
#
# handle_expansion(:parent, child, {json: json, __expand: __expand}) # make sure json and __expand are there!
#
# handle_array_expansion(:subchildren, child, {as: :child, json: json, __expand: __expand}) # We're assuming each of subchildren is actually a Child object
# 																																						#  make sure json and __expand are there!
#
# ```
#
# ```ruby
# in `app/views/parents/_parent.json.jbuilder`
# json.id parent.to_houid
#
# json.some_other_attribute parent.some_other_attribute
# ```

module Controllers::ApiNew::JbuilderExpansions
  extend ActiveSupport::Concern
  included do
    @__expand = Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new

    # The SPaths for the expandable attributes you would like to expand. By default, no attributes are expanded.
    # You can call this multiple times and new calls will override any previous calls
    def set_json_expansion_paths(*expansions)
      @__expand = Controllers::ApiNew::JbuilderExpansions.build_json_expansion_path_tree(*expansions)
    end

    # Builds the {ExpansionTree}. This is rarely needed but could be helpful in certain specific cases
    # @param [Array<String>,Array<ExpansionTree>] paths the paths to expand. If the first item is a {String} then this is an array of SPaths. If the first item is
    # an {ExpansionTree}, this object returns that item
    # @return [ExpansionTree]
    def build_json_expansion_path_tree(*paths)
      Controllers::ApiNew::JbuilderExpansions.build_json_expansion_path_tree(*paths)
    end

    # Configures an attribute which can be expanded in an jbuilder template
    # When shrunk, if you pass this is the equivalent of writing:
    # `json.set! attribute, source&.to_houid` # This assumes you passed the :attribute as the attribute
    # When expanded, this is the equivalent of:
    # `json.set! attribute do
    #    json.partial! opts[:object]
    #  end`
    #
    # @param [Symbol] attribute the name of the attribute that you would like output.
    # @param [any] source an object which with an attribute which can be expanded
    # @option opts [JbuilderTemplate] :json the JBuilder object being used to generate the outputted JSON This is required.
    # @option opts [ExpansionTree] :__expand the ExpansionTree for this current template. This is required.
    # @option opts [Symbol] :as the method we call on 'object' when expanding the node.
    def handle_expansion(attribute, source, opts = {})
      opts = opts.deep_symbolize_keys
      opts[:__expand] ||= __expand
      ExpansionTreeVisitor.handle_expansion(attribute, source, opts)
    end

    # configures an attribute for an array which can be expanded in a jbuilder template
    #
    # When shrunk, this is the equivalent of writing:
    # ```ruby
    # json.set! attribute, source.map{|i| i&.to_houid}
    # ````
    # When expanded, with the helper of  this is the equivalent of writing:
    # ```ruby
    # json.(attribute) source do |item| # assumes opts[:as] is the same as "attribute"
    #  	 json.partial! item
    # end
    # @param [Symbol] attribute the name of the attribute that you would like output.
    # @param [Enumerable] source an enumerable of objects, each of which has an attribute which can be expanded
    # @option opts [JbuilderTemplate] :json the JBuilder object being used to generate the outputted JSON This is required.
    # @option opts [ExpansionTree] :__expand the ExpansionTree for this current template. This is required.
    # @option opts [Symbol] :as_item the method we call on each of the array items as part of a #handle_array_expansion call.
    # @yieldparam [ItemExpansion] item if block is passed, an ItemExpansion will be yielded for each item for in the partial
    def handle_array_expansion(attribute, source, opts = {}, &block)
      opts = opts.deep_symbolize_keys
      opts[:__expand] ||= __expand
      ExpansionTreeVisitor.handle_array_expansion(attribute, source, opts, &block)
    end

    helper_method :handle_expansion, :handle_array_expansion, :build_json_expansion_path_tree
  end

  def self.build_json_expansion_path_tree(*paths)
    request = ExpansionTree.new
    paths = paths.flatten
    if paths.count == 1
      if paths.first.is_a? String
        request = ExpansionTree.new(*paths)
      elsif paths.first.is_a? ExpansionTree
        request = paths.first
      end
    elsif paths.any?
      request = ExpansionTree.new(*paths)
    end

    request
  end

  # Applies Visitor(ish) pattern to an object. One of these is created for every new partial corresponding to a node in the tree
  #
  # Should not be used directly.
  #
  # @api private
  class ExpansionTreeVisitor
    # the attribute to add to the outputted JSON
    # @return [Symbol]
    attr_reader :attribute

    # the object we're visiting
    attr_reader :object

    # @param [Symbol] attribute the attribute in the outputted JSON
    # @param [Object,Enumerable<object>] object the object being visited. object is an enumerable, then it's an array
    # @option opts [JbuilderTemplate] :json the JBuilder object being used to generate the outputted JSON This is required.
    # @option opts [ExpansionTree] :__expand the ExpansionTree for this current template. This is required.
    # @option opts [Symbol] :as the method we call on 'object' when expanding the node.
    # @option opts [Symbol] :item_as the method we call on each of the array items as part of a #handle_array_expansion call.
    def initialize(attribute, object, opts)
      @attribute = attribute
      @object = object
      @opts = opts.deep_symbolize_keys
    end

    # the JBuilder object being used to generate the outputted JSON
    # @return [JbuilderTemplate] the JBuilder object being used to generate the outputted JSON
    def json
      @opts[:json]
    end

    # the ExpansionTree for the current partial
    # @return [ExpansionTree] the tree for the current partial
    def exp_request
      @opts[:__expand]
    end

    # the method we call on 'object' when expanding the node. Defaults to #attribute
    # @return [Symbol]
    def as
      @opts[:as] || attribute
    end

    # the method we call on each of the array items when expanding the node as part of a #handle_array_expansion call. Defaults to #attribute
    # @return [Symbol]
    def item_as
      @opts[:item_as] || attribute
    end

    def visit_expansion
      if object.nil?
        json.set! attribute, nil
      elsif exp_request.expand? attribute
        json.set! attribute do
          json.partial! object, as: as, __expand: exp_request[attribute]
        end
      else
        json.set! attribute, object&.to_houid
      end
    end

    # If #attribute is not set to expand then create an array of houids from the item in #object like:
    #
    # `json.friends ['friend_3254n132', 'friend_1245']`
    #
    # If #attribute is set to expand then create an array with the objects associated with the items. Alternatively, you
    # can pass a block and this will yield an {ItemExpansion} so you can do your own manipulation of the specific item.
    def visit_array_expansion
      json.set! attribute do
        if !exp_request.expand? attribute
          json.array! object.map(&:to_houid)
        else
          object.each do |item|
            json.child! do
              if block_given?
                yield(ItemExpansion.new(item, item_as, {json: json, __expand: exp_request[attribute]}))
              else
                ItemExpansion.new(item, item_as, {json: json, __expand: exp_request[attribute]}).handle_item_expansion
              end
            end
          end
        end
      end
    end

    def visit_item_expansion
      json.partial! object, as: as, __expand: exp_request
    end

    def self.handle_expansion(attribute, object, opts)
      ExpansionTreeVisitor.new(attribute, object, opts).visit_expansion
    end

    def self.handle_array_expansion(attribute, object, opts, &block)
      ExpansionTreeVisitor.new(attribute, object, opts).visit_array_expansion(&block)
    end
  end

  class ItemExpansion
    attr_reader :item, :as

    def initialize(item, as, opts = {})
      @item = item
      @as = as
      @json = opts[:json]
      @__expand = opts[:__expand]
    end

    def handle_item_expansion(object = nil)
      if object.nil?
        object = item
      end
      ExpansionTreeVisitor.new(nil, object, {as: as, json: @json, __expand: @__expand}).visit_item_expansion
    end
  end

  # an ExpansionTree takes a list of JSON SPath and then generates a tree for calculating what should be expanded
  # To help understand why this a tree, consider the following SPaths: `supporter`, `nonprofit`, `nonprofit.user`.
  # One could describe the SPath expansions as follows:
  #
  # ```ruby
  # (root)
  #  	|
  #	 	|---supporter
  # 	|
  #   |---nonprofit
  #				|
  #				|--- user
  # ```
  #
  # @note You shouldn't be using the details of this class directly, you'll just be passing the object around
  # as part of the various expansion requests
  # @api private
  class ExpansionTree
    attr_accessor :root_node

    # @param [Array<string>] paths the JSON SPaths for this tree
    def initialize(*paths)
      @root_node = Node.new
      parse_paths(paths)
    end

    # @param [string] path the path location to get the {ExpansionTree} subtree
    # @return [ExpansionTree] the {ExpansionTree} at that location
    def [](path)
      if @root_node.leaf?
        ExpansionTree.new
      else
        ExpansionTree.create_from(@root_node[path] || Node.new)

      end
    end

    def expand?(path)
      @root_node.has_key?(path)
    end

    # a node in the ExpansionTree
    class Node < ActiveSupport::HashWithIndifferentAccess
      # @return [boolean] true if this is a leaf node, false otherwise
      def leaf?
        none?
      end
    end

    private

    # given a set of SPaths, build a tree to describe
    def parse_paths(paths = [])
      paths.each do |path|
        working_tree = @root_node
        path.split(".").each do |path_part|
          working_tree[path_part] = Node.new unless working_tree[path_part]
          working_tree = working_tree[path_part]
        end
      end
    end

    def self.create_from(root_tree_node)
      er = ExpansionTree.new
      er.root_node = root_tree_node
      er
    end
  end
end
