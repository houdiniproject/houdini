# frozen_string_literal: true
# this is available in newer versions of rails that we aren't running
if Rails.version < '5.2'
  require "active_support/core_ext/hash/keys"
  require "active_model/errors"
  require "active_model/forbidden_attributes_protection"

  module ActiveModel
    # from https://github.com/rails/rails/blob/26521331e5923a0c50fa50984d2f924e5f26c50b/activemodel/lib/active_model/errors.rb
    class Errors
      # Raised when unknown attributes are supplied via mass assignment.
      class UnknownAttributeError < NoMethodError
        attr_reader :record, :attribute

        def initialize(record, attribute)
          @record = record
          @attribute = attribute
          super("unknown attribute '#{attribute}' for #{@record.class}.")
        end
      end
    end


    # Raised when forbidden attributes are used for mass assignment.
    #
    #   class Person < ActiveRecord::Base
    #   end
    #
    #   params = ActionController::Parameters.new(name: 'Bob')
    #   Person.new(params)
    #   # => ActiveModel::ForbiddenAttributesError
    #
    #   params.permit!
    #   Person.new(params)
    #   # => #<Person id: nil, name: "Bob">
    # from :https://github.com/rails/rails/blob/26521331e5923a0c50fa50984d2f924e5f26c50b/activemodel/lib/active_model/forbidden_attributes_protection.rb
    class ForbiddenAttributesError < StandardError
    end

    # from :https://github.com/rails/rails/blob/26521331e5923a0c50fa50984d2f924e5f26c50b/activemodel/lib/active_model/forbidden_attributes_protection.rb
    module ForbiddenAttributesProtection # :nodoc:
      private
        def sanitize_for_mass_assignment(attributes)
          if attributes.respond_to?(:permitted?)
            raise ActiveModel::ForbiddenAttributesError if !attributes.permitted?
            attributes.to_h
          else
            attributes
          end
        end
        alias :sanitize_forbidden_attributes :sanitize_for_mass_assignment
    end

    # from https://github.com/rails/rails/blob/26521331e5923a0c50fa50984d2f924e5f26c50b/activemodel/lib/active_model/attribute_assignment.rb
    module AttributeAssignment
      include ActiveModel::ForbiddenAttributesProtection

      # Allows you to set all the attributes by passing in a hash of attributes with
      # keys matching the attribute names.
      #
      # If the passed hash responds to <tt>permitted?</tt> method and the return value
      # of this method is +false+ an <tt>ActiveModel::ForbiddenAttributesError</tt>
      # exception is raised.
      #
      #   class Cat
      #     include ActiveModel::AttributeAssignment
      #     attr_accessor :name, :status
      #   end
      #
      #   cat = Cat.new
      #   cat.assign_attributes(name: "Gorby", status: "yawning")
      #   cat.name # => 'Gorby'
      #   cat.status # => 'yawning'
      #   cat.assign_attributes(status: "sleeping")
      #   cat.name # => 'Gorby'
      #   cat.status # => 'sleeping'
      def assign_attributes(new_attributes)
        if !new_attributes.respond_to?(:stringify_keys)
          raise ArgumentError, "When assigning attributes, you must pass a hash as an argument."
        end
        return if new_attributes.empty?
  
        attributes = new_attributes.stringify_keys
        _assign_attributes(sanitize_for_mass_assignment(attributes))
      end
  
      alias attributes= assign_attributes
  
      private
  
        def _assign_attributes(attributes)
          attributes.each do |k, v|
            _assign_attribute(k, v)
          end
        end
  
        def _assign_attribute(k, v)
          setter = :"#{k}="
          if respond_to?(setter)
            public_send(setter, v)
          else
            raise ActiveModel::Errors::UnknownAttributeError.new(self, k)
          end
        end
    end
  end
else
  puts "Monkeypatch for ActiveModel::AttributeAssignment no longer needed"
end
