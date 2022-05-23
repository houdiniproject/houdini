# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require "active_support/core_ext/hash/indifferent_access"
require "active_support/hash_with_indifferent_access"

# from https://github.com/rails/rails/blob/ac6aa32f7cf66264ba87eabed7c042bb60bcf3a2/activemodel/test/cases/attribute_assignment_test.rb
describe ActiveModel::AttributeAssignment do

  let(:model) {
    Class.new do 
      include ActiveModel::AttributeAssignment

      attr_accessor :name, :description

      def initialize(attributes = {})
        assign_attributes(attributes)
      end

      def broken_attribute=(value)
        raise ErrorFromAttributeWriter
      end

      protected

      attr_writer :metadata
    end

  }

  let(:protected_params) {
    Class.new do 
      attr_accessor :permitted
      alias :permitted? :permitted
  
      delegate :keys, :key?, :has_key?, :empty?, to: :@parameters
  
      def initialize(attributes)
        @parameters = attributes.with_indifferent_access
        @permitted = false
      end
  
      def permit!
        @permitted = true
        self
      end
  
      def [](key)
        @parameters[key]
      end
  
      def to_h
        @parameters
      end
  
      def stringify_keys
        dup
      end
  
      def dup
        super.tap do |duplicate|
          duplicate.instance_variable_set :@permitted, permitted?
        end
      end
    end
  }

  

  before(:each) {
    stub_const("Model", model)
    stub_const("ProtectedParams", protected_params)
    stub_const("ErrorFromAttributeWriter", Class.new(StandardError))

  }

  it "simple assignment" do
    model = Model.new

    model.assign_attributes(name: "hello", description: "world")
    assert_equal "hello", model.name
    assert_equal "world", model.description
  end

  it "assign non-existing attribute" do
    model = Model.new
    error = assert_raises(ActiveModel::Errors::UnknownAttributeError) do
      model.assign_attributes(hz: 1)
    end

    assert_equal model, error.record
    assert_equal "hz", error.attribute
  end

  it "assign private attribute" do
    model = Model.new
    assert_raises(ActiveModel::Errors::UnknownAttributeError) do
      model.assign_attributes(metadata: { a: 1 })
    end
  end

  it "does not swallow errors raised in an attribute writer" do
    assert_raises(ErrorFromAttributeWriter) do
      Model.new(broken_attribute: 1)
    end
  end

  it "an ArgumentError is raised if a non-hash-like object is passed" do
    assert_raises(ArgumentError) do
      Model.new(1)
    end
  end

  it "forbidden attributes cannot be used for mass assignment" do
    params = ProtectedParams.new(name: "Guille", description: "m")

    assert_raises(ActiveModel::ForbiddenAttributesError) do
      Model.new(params)
    end
  end

  it "permitted attributes can be used for mass assignment" do
    params = ProtectedParams.new(name: "Guille", description: "desc")
    params.permit!
    model = Model.new(params)

    assert_equal "Guille", model.name
    assert_equal "desc", model.description
  end

  it "regular hash should still be used for mass assignment" do
    model = Model.new(name: "Guille", description: "m")

    assert_equal "Guille", model.name
    assert_equal "m", model.description
  end

  it "assigning no attributes should not raise, even if the hash is un-permitted" do
    model = Model.new
    assert_nil model.assign_attributes(ProtectedParams.new({}))
  end
end
