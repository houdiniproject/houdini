# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

Dir["#{File.dirname(__FILE__)}/contexts/*"].each do |file|
  require_relative "./contexts/#{File.basename(file, ".rb")}"
end
