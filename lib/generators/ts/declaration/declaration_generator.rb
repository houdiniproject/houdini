# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Ts::DeclarationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)
  def copy_template
    template "template.d.ts.erb", File.join("types", name, "index.d.ts")
  end
end
