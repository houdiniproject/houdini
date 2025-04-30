# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Expect
  def expect_validation_errors(list_of_errors, validators, error_validator_length_should_match = true)
    if list_of_errors.is_a?(ParamValidation::ValidationError)

      list_of_errors = list_of_errors.data
    end
    if list_of_errors.is_a?(Hash)
      list_of_errors = [list_of_errors]
    end
    if validators.is_a?(Hash)
      validators = [validators]
    end
    if error_validator_length_should_match
      expect(list_of_errors.length).to eq(validators.length)
    end

    validators.each { |i|
      expect(list_of_errors.any? { |e| e[:key].to_s == i[:key].to_s && e[:name].to_s == i[:name].to_s }).to eq(true), "#{i[:key]} should have existed for #{i[:name]}"
    }
  end

  def expect_job_queued
    expect(JobQueue).to receive(:queue)
  end

  def expect_job_not_queued
    expect(JobQueue).to_not receive(:queue)
  end

  def match_houid(prefix)
    match(/#{prefix}_[a-zA-Z0-9]{22}/)
  end
end
