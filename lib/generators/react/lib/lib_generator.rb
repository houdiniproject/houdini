class React::LibGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  def copy_file_to_lib
    template 'module.ts.erb', File.join("javascripts/src/lib/", *(class_path + ["#{file_name.underscore}.ts"]))
    template 'module.spec.ts.erb', File.join("javascripts/src/lib/", *(class_path + ["#{file_name.underscore}.spec.ts"]))
  end
end
