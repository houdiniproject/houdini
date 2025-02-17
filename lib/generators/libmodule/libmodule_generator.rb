# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class LibmoduleGenerator < Rails::Generators::NamedBase
  argument :mod_type, type: :string
  source_root File.expand_path("templates", __dir__)
  def copy_file_to_lib
    template "libmodule_template.erb", "lib/#{mod_type.underscore}/#{mod_type.underscore}_#{name.underscore}.rb"
    template "libmodule_spec_template.erb", "spec/lib/#{mod_type.underscore}/#{mod_type.underscore}_#{name.underscore}_spec.rb"
  end
end
