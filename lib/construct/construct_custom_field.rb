# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'import_data'

module ConstructCustomField

	# Given a row of import data (accessible like a hash)...
	# - filter out all the custom field keys (prefixed with 'custom:x')
	# - create an array of hashes for every custom field
	# - used in Supporter.import
	def self.from_import_data(supp_id, h)
		return h.select{|key,_| key =~ /^custom:/}.map{|key,val| {'supporter_id'=>supp_id, 'value'=>val, 'name'=>key.gsub(/^custom:/,'')}}
	end

end

