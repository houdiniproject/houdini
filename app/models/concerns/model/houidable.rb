# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::Houidable
	extend ActiveSupport::Concern
	class_methods do
		###
		# @description: Simplifies using HouIDs for an ActiveRecord class. HouIDs have the format of:
		# prefix_{22 alphanumeric characters}. Prefixes must be unique across an Houdini instance. 
		# Given a prefix, adds the following features to a ActiveRecord class:
		# - Sets a HouID to the id after object initialization (on "after_initialize" callback) if it hasn't already been set
		# - Adds a "before_houid_set" and "after_houid_set" callbacks in case you want do somethings before or after that happens
		# - Adds  "before_houid_set" and "after_houid_set" callbacks if you want to take actions aroun
		# - Adds two new public methods:
		#    - houid_prefix - returns the prefix as a symbol
		#    - generate_houid - creates a new HouID with given prefix
		# @param {string}: the prefix for the HouIDs on this model
		###
		def setup_houid(prefix)
			class_eval <<-RUBY, __FILE__, __LINE__ + 1
								define_model_callbacks :houid_set
								after_initialize :add_houid
								
								# The HouID prefix as a symbol
								def houid_prefix
                    :#{prefix.to_s}
								end
								
								# Generates a HouID using the provided houid_prefix
								def generate_houid
									houid_prefix.to_s + "_" + SecureRandom.alphanumeric(22)
								end
								
								private 
								def add_houid
									run_callbacks(:houid_set) do
										write_attribute(:id, self.generate_houid) unless read_attribute(:id)
									end
								end
						RUBY
		end
	end
end