# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "active_support/core_ext"

module Format
  module Name
    def self.split_full(name)
      return "" if name.nil?

      name.split(/\ (\w+\s*)$/)
    end

    # Format a nonprofit name into an email <from> header
    def self.email_from_np(np_name)
      "\"#{np_name.delete(",").delete('"')}\" <#{Houdini.hoster.support_email}>"
    end
  end
end
