# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails/generators'
class Api::EntityGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  def copy_to_entity
    template 'entity.rb.erb', File.join("app/api/houdini/v1/entities", "#{name.underscore}.rb")
  end
end
