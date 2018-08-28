def expect_validation_errors(actual, input)
  expected_errors = input.with_indifferent_access[:errors]
  expect(actual["errors"]).to match_array expected_errors
end

def create_errors(empty_errors, *wrapper_params)
  output = empty_errors
  wrapper_params.each {|i| output[:errors].push(h(params: [i], messages: grape_error('presence')))}
  output
end

def grape_error(*keys)
  keys.map {|i| I18n.translate("grape.errors.messages." + i, locale: 'en')}
end