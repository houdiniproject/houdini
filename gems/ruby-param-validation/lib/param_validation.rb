# frozen_string_literal: true

require "json"
require "chronic"

class ParamValidation
  # Given a hash of data and a validation hash, check all the validations, raising an Error on the first invalid key
  # @raise [ValidationError] if one or more of the validations fail.
  def initialize(data, validations)
    errors = []
    validations.each do |key, validators|
      val = (key === :root) ? data : (data[key] || data[key.to_s] || data[key.to_sym])
      next if validators[:required].nil? && val.nil?

      validators.each do |name, arg|
        validator = @@validators[name]
        msg = validations[key][:message]
        next unless validator

        is_valid = @@validators[name].call(val, arg, data)
        msg_proc = @@messages[name]
        msg ||= @@messages[name].call(key: key, data: data, val: val, arg: arg) if msg_proc
        errors.push(msg: msg, data: {key: key, val: val, name: name, msg: msg}) unless is_valid
      end
    end
    if errors.length == 1
      raise ValidationError.new(errors[0][:msg], errors[0][:data])
    elsif errors.length > 1
      msg = errors.collect { |e| e[:msg] }.join('\n')
      raise ValidationError.new(msg, errors.collect { |e| e[:data] })
    end
  end

  def self.messages
    @@messages
  end

  def self.set_message(name, &block)
    @@messages[name] = block
  end

  def self.validators
    @@validators
  end

  def self.add_validator(name, &block)
    @@validators[name] = block
  end

  def self.structure_validators
    @@structure_validators
  end

  def self.add_structure_validator(name, &block)
    @@structure_validators[name] = block
  end

  # In each Proc
  #  - val is the value we are actually validating from the data passed in
  #  - arg is the argument passed into the validator (eg for {required: true}, it is `true`)
  #  - data is the entire set of data
  @@validators = {
    required: ->(val, _arg, _data) { !val.nil? },
    absent: ->(val, _arg, _data) { val.nil? },
    not_blank: ->(val, _arg, _data) { val.is_a?(String) && !val.empty? },
    not_included_in: lambda { |val, arg, _data|
                       begin
                         !arg.include?(val)
                       rescue
                         false
                       end
                     },
    included_in: lambda { |val, arg, _data|
                   begin
                     arg.include?(val)
                   rescue
                     false
                   end
                 },
    format: lambda { |val, arg, _data|
              begin
                val =~ arg
              rescue
                false
              end
            },
    is_integer: ->(val, _arg, _data) { val.is_a?(Integer) || val =~ /\A[+-]?\d+\Z/ },
    is_float: lambda { |val, _arg, _data|
                val.is_a?(Float) || (begin
                  !!Float(val)
                rescue
                  false
                end)
              },
    min_length: lambda { |val, arg, _data|
                  begin
                    val.length >= arg
                  rescue
                    false
                  end
                },
    max_length: lambda { |val, arg, _data|
                  begin
                    val.length <= arg
                  rescue
                    false
                  end
                },
    length_range: lambda { |val, arg, _data|
                    begin
                      arg.cover?(val.length)
                    rescue
                      false
                    end
                  },
    length_equals: ->(val, arg, _data) { val.length == arg },
    is_reference: ->(val, _arg, _data) { (val.is_a?(Integer) && val >= 0) || val =~ /\A\d+\Z/ || val == "" },
    equals: ->(val, arg, _data) { val == arg },
    min: lambda { |val, arg, _data|
           begin
             val >= arg
           rescue
             false
           end
         },
    max: lambda { |val, arg, _data|
           begin
             val <= arg
           rescue
             false
           end
         },
    is_array: ->(val, _arg, _data) { val.is_a?(Array) },
    is_hash: ->(val, _arg, _data) { val.is_a?(Hash) },
    is_json: ->(val, _arg, _data) { ParamValidation.is_valid_json?(val) },
    in_range: lambda { |val, arg, _data|
                begin
                  arg.cover?(val)
                rescue
                  false
                end
              },
    is_a: ->(val, arg, _data) { arg.is_a?(Enumerable) ? arg.any? { |i| val.is_a?(i) } : val.is_a?(arg) },
    can_be_date: ->(val, _arg, _data) { val.is_a?(Date) || val.is_a?(DateTime) || Chronic.parse(val) },
    array_of_hashes: ->(_val, arg, data) { data.is_a?(Array) && data.map { |pair| ParamValidation.new(pair.to_h, arg) }.all? }
  }

  @@messages = {
    required: ->(h) { "#{h[:key]} is required" },
    absent: ->(h) { "#{h[:key]} must not be present" },
    not_blank: ->(h) { "#{h[:key]} must not be blank" },
    not_included_in: ->(h) { "#{h[:key]} must not be included in #{h[:arg].join(", ")}" },
    included_in: ->(h) { "#{h[:key]} must be one of #{h[:arg].join(", ")}" },
    format: ->(h) { "#{h[:key]} doesn't have the right format" },
    is_integer: ->(h) { "#{h[:key]} should be an integer" },
    is_float: ->(h) { "#{h[:key]} should be a float" },
    min_length: ->(h) { "#{h[:key]} has a minimum length of #{h[:arg]}" },
    max_length: ->(h) { "#{h[:key]} has a maximum length of #{h[:arg]}" },
    length_range: ->(h) { "#{h[:key]} should have a length within #{h[:arg]}" },
    length_equals: ->(h) { "#{h[:key]} should have a length of #{h[:arg]}" },
    is_reference: ->(h) { "#{h[:key]} should be an integer or blank" },
    equals: ->(h) { "#{h[:key]} should equal #{h[:arg]}" },
    min: ->(h) { "#{h[:key]} must be at least #{h[:arg]}" },
    max: ->(h) { "#{h[:key]} cannot be more than #{h[:arg]}" },
    in_range: ->(h) { "#{h[:key]} should be within #{h[:arg]}" },
    is_json: ->(h) { "#{h[:key]} should be valid JSON" },
    is_hash: ->(h) { "#{h[:key]} should be a hash" },
    is_a: ->(h) { "#{h[:key]} should be of the type(s): #{h[:arg].is_a?(Enumerable) ? h[:arg].join(", ") : h[:arg]}" },
    can_be_date: ->(h) { "#{h[:key]} should be a datetime or be parsable as one" },
    array_of_hashes: ->(_h) { "Please pass in an array of hashes" }
  }

  # small utility for testing json validity
  def self.is_valid_json?(str)
    JSON.parse(str)
    true
  rescue
    false
  end

  # Special error class that holds all the error data for reference
  class ValidationError < TypeError
    attr_reader :data

    # @param [String] msg message for the validation error(s). Multiple error
    #   messages are split by new lines (\n)
    # @param [Hash, Array<Hash>] data information about the validation failure
    #   or failures. If one failure, a single failure hash is returned, if multiple, an array is returned.
    #   Each failure hash has the following:
    #     * :key - the [Symbol] of the key in the hash where verification failed
    #     * :val - the value of pair in the hash selected by :key
    #     * :name - the [Symbol] for the verification which failed
    #     * :msg - the [String] for the msg for the verifications which failed
    def initialize(msg, data)
      @data = data
      super(msg)
    end
  end
end
