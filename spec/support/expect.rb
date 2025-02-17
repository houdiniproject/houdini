# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Expect
  def expect_validation_errors(list_of_errors, validators, error_validator_length_should_match = true)
    if list_of_errors.is_a?(ParamValidation::ValidationError)

      list_of_errors = list_of_errors.data
    end
    list_of_errors = [list_of_errors] if list_of_errors.is_a?(Hash)
    validators = [validators] if validators.is_a?(Hash)
    if error_validator_length_should_match
      expect(list_of_errors.length).to eq(validators.length)
    end

    validators.each do |i|
      expect(list_of_errors.any? { |e| e[:key].to_s == i[:key].to_s && e[:name].to_s == i[:name].to_s }).to eq(true), "#{i[:key]} should have existed for #{i[:name]}"
    end
  end

  def match_houid(prefix)
    match(/#{prefix}_[a-zA-Z0-9]{22}/)
  end

  def match_json(args = {})
    match(args.deep_stringify_keys)
  end
end
