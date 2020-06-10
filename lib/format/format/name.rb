# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'active_support/core_ext'

module Format
  module Name
    def self.split_full(name)
      return '' if name.nil?

      name.split(/\ (\w+\s*)$/)
    end

    # Format a nonprofit name into an email <from> header
    def self.email_from_np(np_name)
      "\"#{np_name.delete(',').delete('"')}\" <#{Houdini.support_email}>"
    end
  end
end
