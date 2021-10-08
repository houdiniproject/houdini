

class Base
        include ActiveModel::Model
        include ActiveModel::Validations
        include ActiveModel::Validations::Callbacks


        def self.validate_nested_attribute(*attributes)
            validates_with NestedAttributesValidator, _merge_attributes(attributes)
        end
        

        private

        def _merge_attributes(attr_names)
            options = attr_names.extract_options!.symbolize_keys
            attr_names.flatten!
            options[:attributes] = attr_names
            options
          end

        class NestedAttributesValidator < ActiveModel::EachValidator
            def initialize(options)
                @model_class = options[:model_class]
                super
            end

            def validate_each(record, attribute, value)
                inner_validator = @model_class.new(value) unless value.is_a? @model_class
                return if inner_validator.valid?
                add_nested_errors_for(record, attribute, inner_validator)
            end

            def add_nested_errors_for(record, attribute, other_validator)
                record.errors.messages[attribute] = other_validator.errors.messages
            end
        end
    end

