# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class LibmoduleGenerator < Rails::Generators::NamedBase
  argument :mod_type, :type => :string
  source_root File.expand_path('../templates', __FILE__)
  def copy_file_to_lib
    template 'libmodule_template.erb', "lib/#{mod_type.underscore}/#{mod_type.underscore}_#{name.underscore}.rb"
    template 'libmodule_spec_template.erb', "spec/lib/#{mod_type.underscore}/#{mod_type.underscore}_#{name.underscore}_spec.rb"
  end
end
