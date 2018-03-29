# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module React
  class PackrootGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    def copy_file_to_app
      template 'page.ts.erb', "javascripts/app/#{file_name.underscore}.ts"
      generate 'react:component', "#{file_name.underscore}/#{file_name.underscore}"
    end
  end
end

