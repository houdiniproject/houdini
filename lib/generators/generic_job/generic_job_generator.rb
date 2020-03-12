# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class GenericJobGenerator < Rails::Generators::NamedBase
  argument :attribs, :type => :array
  source_root File.expand_path('../templates', __FILE__)
  def copy_file_to_lib
    template 'generic_job_template.erb', "lib/job_types/#{name.underscore}.rb"
    template 'generic_job_spec_template.erb', "spec/lib/job_types/#{name.underscore}_spec.rb"
  end
end
