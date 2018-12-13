# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Validators::LessThanOrEqual < Grape::Validations::Base
  def validate_param!(attr_name, params)
    unless params[attr_name] <= @option
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: translate(:less_than_or_equal, value: @option)
    end
  end


  def translate(key, **options)
    if key.is_a? Symbol
      key = Grape::Exceptions::Base.BASE_MESSAGES_KEY + "." + key
    end

    options = options.dup
    options[:default] &&= options[:default].to_s
    message = ::I18n.translate(key, **options)
    message.present? ? message : ::I18n.translate(key, locale: FALLBACK_LOCALE, **options)
  end
end