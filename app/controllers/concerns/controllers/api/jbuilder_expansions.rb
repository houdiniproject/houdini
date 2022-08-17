# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::Api::JbuilderExpansions
	extend ActiveSupport::Concern
	included do
		@__expand = Controllers::Api::JbuilderExpansions::ExpansionRequest.new

		def set_expansions(*expansions)
			@__expand = Controllers::Api::JbuilderExpansions.set_expansions(*expansions)
		end

		def request_expansions(*expansions)
			Controllers::Api::JbuilderExpansions.set_expansions(*expansions)
		end

		def handle_expansion(attribute, object, opts = {})
			opts = opts.deep_symbolize_keys
			opts[:__expand] ||= __expand
			ExpansionRequestProcessor.handle_expansion(attribute, object, opts)
		end

		def handle_array_expansion(attribute, object, opts = {}, &block)
			opts[:__expand] ||= __expand
			ExpansionRequestProcessor.handle_array_expansion(attribute, object, opts, &block)
		end

		def handle_item_expansion(object, opts = {})
			opts[:__expand] ||= __expand
			ExpansionRequestProcessor.handle_item_expansion(object, opts)
		end

		helper_method :handle_expansion, :handle_array_expansion, :handle_item_expansion, :request_expansions
	end

	def self.set_expansions(*expansions)
		request = ExpansionRequest.new
		expansions = expansions.flatten
		if expansions.count == 1
			case expansions.first
			when String
				request = ExpansionRequest.new(*expansions)
			when ExpansionRequest
				request = expansions.first
			end
		elsif expansions.any?
			request = ExpansionRequest.new(*expansions)
		end

		request
	end

	class ExpansionRequestProcessor
		attr_reader :attribute, :object

		def initialize(attribute, object, opts)
			@attribute = attribute
			@object = object
			@opts = opts.deep_symbolize_keys
		end

		def json
			@opts[:json]
		end

		def exp_request
			@opts[:__expand]
		end

		def as
			@opts[:as] || attribute
		end

		def item_as
			@opts[:item_as] || attribute
		end

		def handle_expansion
			if object.nil?
				json.set! attribute, nil
			elsif exp_request.expand? attribute
				json.set! attribute do
					json.partial! object, as: as, __expand: exp_request[attribute]
				end
			else
				json.set! attribute, object&.id
			end
		end

		def handle_array_expansion
			json.set! attribute do
				if exp_request.expand? attribute
					object.each do |item|
						json.child! do
							yield(item, { json: json, __expand: exp_request[attribute], as: item_as })
						end
					end
				else
					json.array! object.map(&:id)
				end
			end
		end

		def handle_item_expansion
			json.partial! object, as: as, __expand: exp_request
		end

		def self.handle_expansion(attribute, object, opts)
			ExpansionRequestProcessor.new(attribute, object, opts).handle_expansion
		end

		def self.handle_array_expansion(attribute, object, opts, &block)
			ExpansionRequestProcessor.new(attribute, object, opts).handle_array_expansion(&block)
		end

		def self.handle_item_expansion(object, opts)
			opts = opts.deep_symbolize_keys
			ExpansionRequestProcessor.new(nil, object, opts).handle_item_expansion
		end
	end

	class ExpansionRequest
		attr_accessor :path_tree

		def initialize(*paths)
			@path_tree = Node.new
			parse_paths(paths)
		end

		def [](path)
			if @path_tree.leaf?
				ExpansionRequest.new
			else
				ExpansionRequest.create_from(@path_tree[path] || Node.new)

			end
		end

		def expand?(path)
			@path_tree.has_key?(path)
		end

		class Node < ActiveSupport::HashWithIndifferentAccess
			def leaf?
				none?
			end
		end

		private

		def parse_paths(paths = [])
			paths.each do |path|
				working_tree = @path_tree
				path.split('.').each do |path_part|
					working_tree[path_part] = Node.new unless working_tree[path_part]
					working_tree = working_tree[path_part]
				end
			end
		end

		def self.create_from(tree)
			er = ExpansionRequest.new
			er.path_tree = tree
			er
		end
	end
end
