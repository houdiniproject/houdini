# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# require 'support/contexts/shared_donation_charge_context'
# require 'support/contexts/shared_rd_donation_value_context'
# require 'support/contexts/disputes_context'
Dir["#{File.dirname (__FILE__)}/contexts/*"].each do |file|
  require_relative "./contexts/#{File.basename(file, ".rb")}" 
end
