# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module Model::Jbuilder
	extend ActiveSupport::Concern
	class_methods do

		def add_builder_expansion(*args, **kwargs)
			builder_expansions.add_builder_expansion(*args, **kwargs)
		end

		def builder_expansions
			@builder_expansions ||= BuilderExpansionSet.new
		end
	end

	included do
		#
		# Simplify using Jbuilder on models. Does the following things:
		# * takes every attribute set by in add_builder_expansion and either returns them as an id or that attribute's expansion via Jbuilder.
		#		If the attribute is a enumerable, then it returns an an array of id or the expanded version of the attribute
		# * presets the id as the `id` attribute of the JBuilder
		# * presets the `object` attribute of the JBuilder block as the snakecased version of the class name
		#
		# @param [Symbol] *expand the list of model attributes to expand as set via `add_builder_expansion`. If one of items of `expand` is :all,
		# all of the items are expanded.
		#
		# @return [Jbuilder] the Jbuilder object for the model
		#
		def init_builder(*expand, &block)
			builder_expansions = self.class.builder_expansions
			expand_all = expand.include? :all
			Jbuilder.new do | json|
				json.(self, :id)
				json.object self.class.name.underscore
				builder_expansions.keys.each do |k|
					if expand_all || expand.include?(k)
						json.set! builder_expansions.get_by_key(k).json_attrib, builder_expansions.get_by_key(k).to_expand.(self)
					else
						json.set! builder_expansions.get_by_key(k).json_attrib, builder_expansions.get_by_key(k).to_id.(self)
					end
				end
				yield(json) if block
			end
		end
	end

	class BuilderExpansionSet < Set
		def add_builder_expansion(*args, **kwargs)
			be = nil
			if args.any? || kwargs.any?
				if (args.count == 1 && kwargs.any?)
					be = BuilderExpansion.new(**{key: args[0]}.merge(kwargs))
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
			map{|i| i.key}
		end

		def get_by_key(key) 
			select{|i| i.key == key}.first
		end
	end

	class BuilderExpansion
		include ActiveModel::AttributeAssignment
		attr_accessor :key, :json_attrib, :to_id,
			:to_expand

		def initialize(new_attributes)
			assign_attributes(new_attributes)
		end

		def json_attrib
			@json_attrib || key
		end

		def to_id
			to_id_func = @to_id || -> (model){model.id}
			
			return -> (model, be=self) do
				if be.model_attrib_enumerable?(model)
					be.attrib_value(model).map do |i| 
						to_id_func.call(i)
					end
				else
					to_id_func.call(be.attrib_value(model))
				end
			end
		end

		def to_expand
			to_expand_func = @to_expand || -> (model) {model.to_builder}
			
			return -> (model, be=self) do
				if be.model_attrib_enumerable?(model)
					be.attrib_value(model).map do |i| 
						to_expand_func.call(i).attributes!
					end
				else
					to_expand_func.call(be.attrib_value(model)).attributes!
				end
			end
		end

		def attrib_value(model)
			model.send(self.key)
		end

		def model_attrib_enumerable?(model) 
			attrib_value(model).respond_to? :each
		end
	end
end