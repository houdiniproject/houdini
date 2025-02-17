module Image::AttachmentExtensions
  extend ActiveSupport::Concern
  class_methods do
    def has_one_attached_with_sizes(attribute_name, sizes)
      if sizes.nil? || !sizes.is_a?(Hash) || !sizes.any?
        raise ArgumentError, "You must pass a valid hash of sizes"
      end
      attribute = attribute_name.to_s

      # clean up sizes
      sizes.each_key do |key|
        value = sizes[key]
        if value.is_a?(Numeric)
          sizes[key] = [value, value]
        elsif value.is_a?(Array) && value.count == 1 && value.all? { |i| i.is_a?(Numeric) }
          sizes[key] = [value[0], value[0]]
        elsif value.is_a?(Array) && value.count == 2 && value.all? { |i| i.is_a?(Numeric) }
          sizes[key] = [value[0], value[1]]
        else
          raise ArgumentError, "#{value} was not a valid size."
        end
      end

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
                def #{attribute}_by_size(size)
                     case (size)
                    #{sizes.map do |k, v| 
                      <<-INNER
                        when :#{k.to_sym}
                            return #{attribute}.variant(resize_to_limit: [#{v[0]}, #{v[1]}])
                      INNER
                    end.join("\n")}
                     else
                        raise ArgumentError, ":" + size.to_s + " is not a valid size. Valid sizes are: #{sizes.keys.map { |i| ":" + i.to_s }.join(", ")}"
                     end
                end
      RUBY
    end

    def has_one_attached_with_default(attribute_name, default_path, **options)
      after_save do
        attribute = send(attribute_name)
        unless attribute.attached?
          attribute.attach(io: File.open(default_path), **options)
        end
        self
      end
    end
  end
end
