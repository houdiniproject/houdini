# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# License: ISC
# From https://github.com/ruby-grape/grape/blob/f1ec68451bea9c4b051f7be0f47648bc7aace065/lib/grape/validations/validators/at_least_one_of.rb
module Grape
  module Validations
    require 'grape/validations/validators/multiple_params_base'
    class AtLeastOneOfValidator < MultipleParamsBase
      def validate!(params)
        super
        if scope_requires_params && no_exclusive_params_are_present
          raise Grape::Exceptions::Validation, params: all_keys_with_full_name, message: message(:at_least_one)
        end
        params
      end

      private

      def no_exclusive_params_are_present
        scoped_params.any? { |resource_params| keys_in_common(resource_params).empty? }
      end

      def all_keys_with_full_name
        attrs.map{|i| @scope.full_name(i)}
      end
    end
  end
end