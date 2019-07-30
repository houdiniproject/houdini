# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailJobGenerator < Rails::Generators::NamedBase
  argument :attribs, type: :array
  source_root File.expand_path('templates', __dir__)
  def copy_file_to_lib
    template 'email_job_template.erb', "lib/job_types/#{name.underscore}.rb"
    template 'email_job_spec_template.erb', "spec/lib/job_types/#{name.underscore}_spec.rb"
  end
end
