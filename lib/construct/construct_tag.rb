require 'import_data'

module ConstructTag

	# Given a row of import data (accessible like a hash)...
	# - use only the 'tags' column from the import row
	# - split the tags by commas and trim whitespace from the ends
	# - return an array of hash data for every tag_join to be created
	# - called from Supporter.import
	def self.from_import_data(supp_id, h)
		return [] if h['tags'].blank?
		return  h['tags'].split(';').map(&:strip).map{|name| {'supporter_id' => supp_id, 'name' => name}}
	end

end
