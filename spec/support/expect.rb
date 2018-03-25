module Expect

  def expect_validation_errors(list_of_errors, validators, error_validator_length_should_match=true)
    if (list_of_errors.is_a?(ParamValidation::ValidationError))

      list_of_errors = list_of_errors.data
    end
    if (list_of_errors.is_a?(Hash))
      list_of_errors = [list_of_errors]
    end
    if (validators.is_a?(Hash))
      validators = [validators]
    end
    if (error_validator_length_should_match)
      expect(list_of_errors.length).to eq(validators.length)
    end

    validators.each{|i|
      expect(list_of_errors.any?{|e| e[:key].to_s == i[:key].to_s && e[:name].to_s == i[:name].to_s}).to eq(true), "#{i[:key]} should have existed for #{i[:name]}"
    }
  end

  def expect_email_queued
    expect(EmailJobQueue).to receive(:queue)
  end
end
