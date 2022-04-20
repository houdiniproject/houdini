# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Fix for CVE-2020-5267
if Rails.version < '5.2.4.2'
  # from https://github.com/advisories/GHSA-65cv-r6x7-79hv
  ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP.merge!(
  {
    "`" => "\\`",
    "$" => "\\$"
  }
  )

  module ActionView::Helpers::JavaScriptHelper
    alias :old_ej :escape_javascript
    alias :old_j :j

    def escape_javascript(javascript)
      javascript = javascript.to_s
      if javascript.empty?
        result = ""
      else
        result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"']|[`]|[$])/u, JS_ESCAPE_MAP)
      end
      javascript.html_safe? ? result.html_safe : result
    end

    alias :j :escape_javascript
  end
else
  puts "Monkeypatch for ActionView::Helpers::JavaScriptHelper no longer needed"
end

