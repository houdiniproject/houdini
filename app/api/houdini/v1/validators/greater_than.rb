# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Validators::GreaterThan < Houdini::V1::Validators::HoudiniValidator
  def validate_param!(attr_name, params)
    unless params[attr_name] > @option
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'MESSAGE'
    end
  end
end