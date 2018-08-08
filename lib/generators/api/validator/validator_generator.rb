# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails/generators'
class Api::ValidatorGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_to_validators
    post_api_part = File.join("houdini/v1/validators", "#{name.underscore}.rb")
    output_file = File.join("app/api", post_api_part )
    template 'validator.rb.erb', output_file
  end

  def add_to_root_validations
    post_api_part = File.join("houdini/v1/validators", "#{name.underscore}")
    append_to_file "app/api/houdini/v1/validations.rb", "\nrequire '#{post_api_part}'"
  end
end
