# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::AsMoneyable
  extend ActiveSupport::Concern
  class_methods do
    def moneyable_attributes
      @moneyable_attributes ||= []
    end

    # For every attribute in attr, this creates a new getter with the postfix of `_as_money` that
    # returns the the attribute as an Amount, with the currency from
    # the currency attribute of the class.
    def as_money(*attr)
      attr.each do |a|
        moneyable_attributes << a
        class_eval <<-RUBY, __FILE__, __LINE__ + 1 # rubocop:disable Style/DocumentDynamicEvalDefinition
          def #{a}_as_money
            Amount.new(#{a} || 0, currency)
          end
        RUBY
      end
    end
  end
end
