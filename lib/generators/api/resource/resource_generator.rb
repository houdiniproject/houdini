# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails/generators'
class Api::ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  def copy_to_resource
    template 'resource.rb.erb', File.join("app/api/houdini/v1", "#{name.underscore}.rb")
  end

  def copy_to_spec
    template 'spec.rb.erb', File.join("spec/api/houdini/", "#{name.underscore}_spec.rb")
  end

  def add_to_root_api
    inject_into_file "app/api/houdini/v1/api.rb", "mount Houdini::V1::#{ name.camelcase} => \"/#{name.underscore}\"\n  ", before:"# Additional mounts are added via generators above this line"
  end
end
