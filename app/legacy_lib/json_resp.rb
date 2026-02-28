# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# Provide a declarative json validation and error responses for the rails 'render' method in controllers
#
# The return value of the block you pass into #when_valid should look like {status: code, json: data}
#
# Concerns of this lib are:
# * Validate the params, only running a block when valid
# * Provide a declarative system for request parameter requirements
# * Respond with proper codes and error messages for everything

class JsonResp
  attr_accessor :errors

  def initialize(params, &block)
    @params = params
    validation = JsonResp::Validation.new(params)
    validation.instance_exec(params, &block)
    @errors = validation.errors
  end

  def when_valid
    return {status: 422, json: {errors: @errors}} if @errors.any?

    begin
      @response = yield(@params)
    rescue Exception => e
      @response = {status: 500, json: {error: "We're sorry, but something went wrong. We've been notified about this issue."}}
      puts e
      puts e.backtrace.first(10)
    end
    @response
  end

  # Validation of a set of request parameters
  class Validation
    attr_accessor :errors, :params

    def initialize(params)
      @params = params
      @errors = []
    end

    def requires(*keys)
      @errors.concat keys.select { |k| @params[k].blank? }.map { |k| "#{k} required" }
      Param.new(keys, @errors, @params)
    end

    def requires_either(key1, key2)
      error_message = "#{key1} or #{key2} is required"
      if @params[key1].blank? && @params[key2].blank?
        @errors << error_message
      else
        @errors.concat [key1, key2].select { |k| @params[k].blank? }.map { |k| "#{k} required" }
      end
      Param.new([key1, key2], @errors, @params)
    end

    def optional(*keys)
      keys_to_check = keys.select { |k| @params[k].present? }
      Param.new(keys_to_check, @errors, @params)
    end
  end

  class Param
    # param validation methods
    # To make more validators, you can extend this class
    # All methods here are no-ops if the key was optional and is not present

    attr_accessor :keys, :errors, :params

    def initialize(keys, errors, params)
      @keys = keys.reject { |k| params[k].nil? }
      @errors = errors
      @params = params
    end

    def as_string
      @errors.concat @keys.reject { |k| @params[k].is_a?(String) }.map { |k| "#{k} must be a string" }
      self
    end

    def as_int
      @errors.concat @keys
        .reject { |k| @params[k].is_a?(Integer) || @params[k].to_i.to_s == @params[k] }
        .map { |k| "#{k} must be an integer" }
      self
    end

    def with_format(regex)
      @errors.concat @keys.reject { |k| @params[k] =~ regex }.map { |k| "#{k} must match: #{regex}" }
      self
    end

    def one_of(*vals)
      @errors.concat @keys.reject { |k| vals.include?(@params[k]) }.map { |k| "#{k} must be one of: #{vals.join(", ")}" }
      self
    end

    def nested(&block)
      @errors.concat @keys.map { |k| Validation.new(@params[k]).instance_exec(@params, &block).errors }.flatten
      self
    end

    def as_array
      @errors.concat @keys.reject { |k| @params[k].is_a?(Array) }.map { |k| "#{k} must be an array" }
    end

    def array_of(&block)
      @errors.concat @keys.reject { |k| @params[k].is_a?(Array) }.map { |k| "#{k} must be an array" }
      @errors.concat @keys.map { |k| @params[k].map { |h| Validation.new(h).instance_exec(@params, &block).errors } }.flatten
      self
    end

    def as_date
      with_format(/\d\d\d\d-\d\d-\d\d/)
      @errors.concat @keys.map { |k| [k].concat @params[k].split("-").map(&:to_i) }
        .reject { |_key, year, month, day| year.present? && year > 1000 && year < 3000 && month.present? && month > 0 && month < 13 && day.present? && day > 0 && day < 32 }
        .map { |k, _, _, _| "#{k} must be a valid date" }
    end

    def min(n)
      @errors.concat @keys.reject { |k| @params[k] >= n }.map { |k| "#{k} must be at least #{n}" }
      self
    end

    def max(n)
      @errors.concat @keys.reject { |k| @params[k] <= n }.map { |k| "#{k} must be less than #{n + 1}" }
      self
    end

    # TODO: min_len, max_len, as_float, as_currency, as_time, as_datetime
    # TODO return err resp on unrecognized params
  end
end
