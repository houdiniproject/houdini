# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class React::ComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_file_to_component
    template 'component.tsx.erb', File.join('javascripts/src/components', *(class_path + ["#{file_name.camelize}.tsx"]))
    template 'component.spec.tsx.erb', File.join('javascripts/src/components', *(class_path + ["#{file_name.camelize}.spec.tsx"]))
  end
end
