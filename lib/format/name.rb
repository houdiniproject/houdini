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
			"\"#{np_name.gsub(',', '').gsub("\"", '')}\" <#{Settings.mailer.email}>"
    end
	end
end
