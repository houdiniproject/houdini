module Houdini::V1::Helpers::RescueHelper
  extend Grape::API::Helpers

  def rescue_ar_invalid(error, class_to_param=nil)
    param_name = class_to_param ? class_to_param[error.record.class] : error.record.class.name.downcase
    if (param_name)
      errors = error.record.errors.keys.map {|k|

        errors = error.record.errors[k].uniq
        errors.map{|error| Grape::Exceptions::Validation.new(

            params: ["#{param_name}[#{k.to_s}]"],
            message: error

        )}
      }
      validation_errors = Grape::Exceptions::ValidationErrors.new(errors:errors.flatten)
      validation_errors_output(validation_errors)
    else
      raise error
    end
  end

  def validation_errors_output(error)
    output = {errors: error}
    error! output, 400
  end
end