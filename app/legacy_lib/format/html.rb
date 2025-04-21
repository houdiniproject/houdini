# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Format
  module HTML
    def self.has_only_empty_tags(html_str)
      true if html_str && html_str.gsub(/<[^>]*>/ui, "").gsub("&nbsp;", "").strip == ""
    end
  end
end
