# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Validators::IsEqualTo < Grape::Validations::Base
  def validate_param!(attr_name, params)
    if params[attr_name] != params[@option]
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name), @scope.full_name(@option)], message: message(:is_equal_to)
    end
  end
end