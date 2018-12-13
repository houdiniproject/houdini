# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Validators::HoudiniValidator < Grape::Validations::Base

  # originally from Ruby Grape
  def translate(key, **options)
    if key.is_a? Symbol
      key = "grape.errors.messages."  + message(key).to_s
    end

    options = options.dup
    options[:default] &&= options[:default].to_s
    message = ::I18n.translate(key, **options)
    message.present? ? message : ::I18n.translate(key, locale: :en, **options)
  end
end
