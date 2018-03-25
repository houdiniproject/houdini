# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Format; module Url

	def self.without_prefix(url)
		url.gsub(/(http(s)?:\/\/)|(www\.)|(\?.*$)|(#.*$)/, '')
	end

	# Given ["What hello", "hi! lol?"]
	# Return ["what-hello", "hi-lol"]
	def self.convert_to_slug(*words)
		return '' if words.empty? || !words.all? # true if any are nil or empty
		words.map do |d| 
			d.strip.downcase
			.gsub(/['`]/,'') # no apostrophes
			.gsub(/\./,'') # no dots
			.gsub(/\s*@\s*/, ' at ') # @ -> at
			.gsub(/\s*&\s*/, ' and ') # & -> and
			.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '-') # replace oddballs with hyphen
			.gsub(/\A[-\.]+|[-\.]+\z/,'') # strip leading/trailing hyphens
		end.join("/")
	end

	def self.concat(*urls)
		return urls.join('/').gsub(/([^:])\/\/+/,'\1/')
	end

end; end
