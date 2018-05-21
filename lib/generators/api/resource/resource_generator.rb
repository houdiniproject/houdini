class Api::ResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  def copy_to_resource
    template 'resource.rb.erb', File.join("app/api/houdini/v1", "#{name.underscore}.rb")
  end

  def add_to_root_api
    inject_into_file "app/api/houdini/v1/api.rb", "\tmount Houdini::V1::#{ name.camelcase}\n", after: "class Houdini::V1::API < Grape::API\n"
  end
end
