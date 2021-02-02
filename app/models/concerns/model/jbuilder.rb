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
			:to_expand, :if, :unless, :on_else, :to_attrib

		def initialize(new_attributes)
			assign_attributes(new_attributes)
		end

		def json_attrib
			@json_attrib || key
		end

		def to_id
			if @to_id
				return @to_id
			elsif @to_attrib
				return -> (model, be=self) { to_attrib.(model).id }
			else
				return ->(model,be=self) { model.send(be.key).id}
			end
		end

		def to_expand
			if @to_expand
				return @to_expand
			elsif @to_attrib
				return -> (model, be=self) {	to_attrib.(model).to_builder }
			else
				return ->(model,be=self) { model.send(be.key).to_builder}
			end

			
		end
	end

	
	def init_builder(*expand)
		builder_expansions = self.class.builder_expansions
		Jbuilder.new do | json|
			builder_expansions.keys.each do |k|
				if expand.include? k
					json.set! builder_expansions.get_by_key(k).json_attrib, builder_expansions.get_by_key(k).to_expand.(self)
				else
					json.set! builder_expansions.get_by_key(k).json_attrib, builder_expansions.get_by_key(k).to_id.(self)
				end
			end
			yield(json)
		end
	end
end