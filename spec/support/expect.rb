# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module Expect
	def expect_validation_errors(list_of_errors, validators, error_validator_length_should_match: true) # rubocop:disable Metrics/AbcSize
		list_of_errors = get_list_of_errors(list_of_errors)
		validators = [validators] if validators.is_a?(Hash)
		expect(list_of_errors.length).to eq(validators.length) if error_validator_length_should_match

		validators.each do |i|
			expect(list_of_errors.any? do |e|
											e[:key].to_s == i[:key].to_s && e[:name].to_s == i[:name].to_s
										end).to eq(true), "#{i[:key]} should have existed for #{i[:name]}"
		end
	end

	def match_houid(prefix)
		match(/#{prefix}_[a-zA-Z0-9]{22}/)
	end

	private

	def get_list_of_errors(list_of_errors)
		return list_of_errors.data if list_of_errors.is_a?(ParamValidation::ValidationError)
		return [list_of_errors] if list_of_errors.is_a?(Hash)

		list_of_errors
	end
end
