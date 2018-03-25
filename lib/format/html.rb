# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Format
  module HTML
    def self.has_only_empty_tags(html_str)
      return true if html_str && html_str.gsub(/<[^>]*>/ui,'').gsub("&nbsp;", "").strip == ""
    end
  end
end
