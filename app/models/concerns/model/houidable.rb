# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# rubocop:disable Layout/TrailingWhitespace  # we do this becuase rubocop is bizarrely crashing on this file
module Model::Houidable
  extend ActiveSupport::Concern
  class_methods do
    ###
    # @description: Simplifies using HouIDs for an ActiveRecord class. A Houid (pronounced "Hoo-id") is a unique 
    # identifier for an object. Houids have the format of: prefix_{22 random alphanumeric characters}. A prefix
    # consists of lowercase alphabetical characters. Each class must have its own unique prefix. All of the Houids
    # generated for that class will use that prefix.
    #
    # Given a prefix, adds the following features to a ActiveRecord class:
    # - Sets a HouID to the id after object initialization (on "after_initialize" callback) if
    #		it hasn't already been set
    # - Adds a "before_houid_set" and "after_houid_set" callbacks in case you want do
    #   somethings before or after that happens
    # - Adds  "before_houid_set" and "after_houid_set" callbacks if you want to take actions around
    # - Adds the following public class methods (and instance methods that delegate to this methods):
    #    - houid_prefix - returns the prefix as a symbol
    #    - generate_houid - creates a new HouID with given prefix
    #		 - houid_attribute - the symbol of the attribute on this class that the Houid is assigned to.
    # - Adds the following public instance method:
    # 	 - to_houid - returns the houid for the instance regardless of what `houid_attribute` is.
    # @param prefix {string|Symbol}: the prefix for the HouIDs on this model
    # @param houid_attribute {string|Symbol}: the attribute on this model to assign the Houid to. Defaults to :id.
    ###
    def setup_houid(prefix, houid_attribute = :id)
      
      ######
      # 					define_model_callbacks :houid_set
      # 					after_initialize :add_houid
                
      # 					# The HouID prefix as a symbol
      # 					def houid_prefix
      # 						:supp
      # 					end
                
      # 					# Generates a HouID using the provided houid_prefix
      # 					def generate_houid
      # 						houid_prefix.to_s + "_" + SecureRandom.alphanumeric(22)
      # 					end
                
      # 					private 
      # 					def add_houid
      # 						run_callbacks(:houid_set) do
      # 							write_attribute(:id, self.generate_houid) unless read_attribute(:id)
      # 						end
      # 					end
      #####
      class_eval <<-RUBY, __FILE__, __LINE__ + 1 # rubocop:disable Style/DocumentDynamicEvalDefinition 
								define_model_callbacks :houid_set
								after_initialize :add_houid
								
								delegate :houid_prefix, :houid_attribute, :generate_houid, to: :class

								# The HouID prefix as a symbol
								# def self.houid_prefix
								#		:supp
								# end

								def self.houid_prefix
									:#{prefix}
								end

								def self.houid_attribute
									:#{houid_attribute} 
								end
								
								# Generates a HouID using the provided houid_prefix
								def self.generate_houid
									houid_prefix.to_s + "_" + SecureRandom.alphanumeric(22)
								end

								def to_houid
									self.send(houid_attribute)
								end
								
								private 
								def add_houid
									run_callbacks(:houid_set) do
										write_attribute(self.houid_attribute, self.generate_houid) unless read_attribute(self.houid_attribute)
									end
								end
      RUBY
    end
  end
end

# rubocop:enable Layout/TrailingWhitespace
