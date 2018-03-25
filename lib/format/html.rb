module Format
  module HTML
    def self.has_only_empty_tags(html_str)
      return true if html_str && html_str.gsub(/<[^>]*>/ui,'').gsub("&nbsp;", "").strip == ""
    end
  end
end
