# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module RetrieveActiveRecordItems
  def self.retrieve(data, optional = false)
    data.map { |k, v|
      our_integer = begin
        Integer(v)
      rescue
        nil
      end
      unless (optional && v.nil?) || (our_integer && our_integer > 0)
        raise ArgumentError.new("Value '#{v}' for Key '#{k}' is not valid")
      end

      unless k.is_a? Class
        raise ArgumentError.new("Key '#{k}' is not a class")
      end
      ret = []
      if optional && v.nil?
        ret = [k, nil]
      else
        ret = [k, k.where("id = ?", our_integer).first]
        if ret[1].nil?
          raise ParamValidation::ValidationError.new("ID #{v} is not a valid #{k}", {key: k})
        end
      end
      ret
    }.to_h
  end

  def self.retrieve_from_keys(input, class_to_key_hash, optional = false)
    class_to_key_hash.map { |k, v|
      unless k.is_a? Class
        raise ArgumentError.new("Key '#{k}' is not a class")
      end
      ret = nil
      begin
        item = retrieve({k => input[v]}, optional)
        ret = [v, item[k]]
      rescue ParamValidation::ValidationError
        raise ParamValidation::ValidationError.new("ID #{input[v]} is not a valid #{k}", {key: v})
      rescue ArgumentError
        raise ParamValidation::ValidationError.new("#{input[v]} is not a valid ID for Key '#{v}'", {key: v})
      rescue
        raise ParamValidation::ValidationError.new("#{input[v]} is not a valid ID for Key '#{v}'", {key: v})
      end
      ret
    }.to_h
  end
end
