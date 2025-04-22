# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

Dir["#{File.dirname(__FILE__)}/contexts/*"].each do |file|
  require_relative "./contexts/#{File.basename(file, ".rb")}"
end
