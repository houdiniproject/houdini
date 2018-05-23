# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class React::ComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_file_to_component
    template 'component.tsx.erb', File.join("javascripts/src/components", *(class_path + ["#{file_name.camelize}.tsx"]))
    template 'component.spec.tsx.erb', File.join("javascripts/src/components", *(class_path + ["#{file_name.camelize}.spec.tsx"]))
  end
end
