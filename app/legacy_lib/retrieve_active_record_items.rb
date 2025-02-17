# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module RetrieveActiveRecordItems
  def self.retrieve(data, optional = false)
    data.map do |k, v|
      our_integer = begin
        Integer(v)
      rescue
        nil
      end
      unless (optional && v.nil?) || (our_integer && our_integer > 0)
        raise ArgumentError, "Value '#{v}' for Key '#{k}' is not valid"
      end

      raise ArgumentError, "Key '#{k}' is not a class" unless k.is_a? Class

      ret = []
      if optional && v.nil?
        ret = [k, nil]
      else
        ret = [k, k.where("id = ?", our_integer).first]
        if ret[1].nil?
          raise ParamValidation::ValidationError.new("ID #{v} is not a valid #{k}", key: k)
        end
      end
      ret
    end.to_h
  end

  def self.retrieve_from_keys(input, class_to_key_hash, optional = false)
    class_to_key_hash.map do |k, v|
      raise ArgumentError, "Key '#{k}' is not a class" unless k.is_a? Class

      ret = nil
      begin
        item = retrieve({k => input[v]}, optional)
        ret = [v, item[k]]
      rescue ParamValidation::ValidationError
        raise ParamValidation::ValidationError.new("ID #{input[v]} is not a valid #{k}", key: v)
      rescue ArgumentError
        raise ParamValidation::ValidationError.new("#{input[v]} is not a valid ID for Key '#{v}'", key: v)
      rescue
        raise ParamValidation::ValidationError.new("#{input[v]} is not a valid ID for Key '#{v}'", key: v)
      end
      ret
    end.to_h
  end
end
