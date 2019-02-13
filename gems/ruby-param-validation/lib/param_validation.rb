require 'json'
require 'chronic'

class ParamValidation

  # Given a hash of data and a validation hash, check all the validations, raising an Error on the first invalid key
  # @raise [ValidationError] if one or more of the validations fail.
  def initialize(data, validations)
    errors = []
    validations.each do |key, validators|
      val = key === :root ? data : (data[key] || data[key.to_s] || data[key.to_sym])
      next if validators[:required].nil? && val.nil?
      validators.each do |name, arg|
        validator = @@validators[name]
        msg = validations[key][:message]
        next unless validator
        is_valid = @@validators[name].call(val, arg, data)
        msg_proc = @@messages[name]
        msg ||= @@messages[name].call({key: key, data: data, val: val, arg: arg}) if msg_proc
        errors.push({msg: msg, data: {key: key, val: val, name: name, msg: msg}}) unless is_valid
      end
    end
    if errors.length == 1
      raise ValidationError.new(errors[0][:msg], errors[0][:data])
    elsif errors.length > 1
      msg = errors.collect {|e| e[:msg]}.join('\n')
      raise ValidationError.new(msg, errors.collect{|e| e[:data]})
    end
  end

  def self.messages; @@messages; end
  def self.set_message(name, &block)
    @@messages[name] = block
  end

  def self.validators; @@validators; end
  def self.add_validator(name, &block)
    @@validators[name] = block
  end
  def self.structure_validators; @@structure_validators; end
  def self.add_structure_validator(name, &block)
    @@structure_validators[name] = block
  end

  # In each Proc
  #  - val is the value we are actually validating from the data passed in
  #  - arg is the argument passed into the validator (eg for {required: true}, it is `true`)
  #  - data is the entire set of data
  @@validators = {
    required:  lambda {|val, arg, data| !val.nil?},
    absent: lambda {|val, arg, data| val.nil?},
    not_blank: lambda {|val, arg, data| val.is_a?(String) && val.length > 0},
    not_included_in: lambda {|val, arg, data| !arg.include?(val) rescue false},
    included_in: lambda {|val, arg, data| arg.include?(val) rescue false},
    format: lambda {|val, arg, data| val =~ arg rescue false},
    is_integer: lambda {|val, arg, data| val.is_a?(Integer) || val =~ /\A[+-]?\d+\Z/},
    is_float: lambda {|val, arg, data| val.is_a?(Float) || (!!Float(val) rescue false) },
    min_length: lambda {|val, arg, data| val.length >= arg rescue false},
    max_length: lambda {|val, arg, data| val.length <= arg rescue false},
    length_range: lambda {|val, arg, data| arg.cover?(val.length) rescue false},
    length_equals: lambda {|val, arg, data| val.length == arg},
    is_reference: lambda{|val, arg, data| (val.is_a?(Integer)&& val >=0) || val =~ /\A\d+\Z/ || val == ''},
    equals: lambda {|val, arg, data| val == arg},
    min: lambda {|val, arg, data| val >= arg rescue false},
    max: lambda {|val, arg, data| val <= arg rescue false},
    is_array: lambda {|val, arg, data| val.is_a?(Array)},
    is_hash: lambda {|val, arg, data| val.is_a?(Hash)},
    is_json: lambda {|val, arg, data| ParamValidation.is_valid_json?(val)},
    in_range: lambda {|val, arg, data| arg.cover?(val) rescue false},
    is_a: lambda {|val, arg, data| arg.kind_of?(Enumerable) ? arg.any? {|i| val.is_a?(i)} : val.is_a?(arg)},
    can_be_date: lambda {|val, arg, data| val.is_a?(Date) || val.is_a?(DateTime) || Chronic.parse(val)},
    array_of_hashes: lambda {|val, arg, data| data.is_a?(Array) && data.map{|pair| ParamValidation.new(pair.to_h, arg)}.all?}
  }

  @@messages = {
    required: lambda {|h| "#{h[:key]} is required"},
    absent: lambda {|h| "#{h[:key]} must not be present"},
    not_blank: lambda {|h| "#{h[:key]} must not be blank"},
    not_included_in: lambda {|h| "#{h[:key]} must not be included in #{h[:arg].join(", ")}"},
    included_in: lambda {|h|"#{h[:key]} must be one of #{h[:arg].join(", ")}"},
    format: lambda {|h|"#{h[:key]} doesn't have the right format"},
    is_integer: lambda {|h|"#{h[:key]} should be an integer"},
    is_float: lambda {|h|"#{h[:key]} should be a float"},
    min_length: lambda {|h|"#{h[:key]} has a minimum length of #{h[:arg]}"},
    max_length: lambda {|h|"#{h[:key]} has a maximum length of #{h[:arg]}"},
    length_range: lambda {|h|"#{h[:key]} should have a length within #{h[:arg]}"},
    length_equals: lambda {|h|"#{h[:key]} should have a length of #{h[:arg]}"},
    is_reference: lambda{|h| "#{h[:key]} should be an integer or blank"},
    equals: lambda {|h|"#{h[:key]} should equal #{h[:arg]}"},
    min: lambda {|h|"#{h[:key]} must be at least #{h[:arg]}"},
    max: lambda {|h|"#{h[:key]} cannot be more than #{h[:arg]}"},
    in_range: lambda {|h|"#{h[:key]} should be within #{h[:arg]}"},
    is_json: lambda {|h| "#{h[:key]} should be valid JSON"},
    is_hash: lambda {|h| "#{h[:key]} should be a hash"},
    is_a: lambda  {|h| "#{h[:key]} should be of the type(s): #{h[:arg].kind_of?(Enumerable) ? h[:arg].join(', '): h[:arg]}"},
    can_be_date: lambda  {|h| "#{h[:key]} should be a datetime or be parsable as one"},
    array_of_hashes: lambda {|h| "Please pass in an array of hashes"}
  }

  # small utility for testing json validity
  def self.is_valid_json?(str)
    begin
      JSON.parse(str)
      return true
    rescue => e
      return false
    end
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

