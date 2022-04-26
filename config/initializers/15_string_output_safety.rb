

if Rails.version < '5'
  require 'erb'
  require 'active_support/core_ext/kernel/singleton_class'
  require 'active_support/deprecation'
  class ERB
    module Util
      HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;', "'" => '&#39;' }
      JSON_ESCAPE = { '&' => '\u0026', '>' => '\u003e', '<' => '\u003c', "\u2028" => '\u2028', "\u2029" => '\u2029' }
      HTML_ESCAPE_REGEXP = /[&"'><]/
      HTML_ESCAPE_ONCE_REGEXP = /["><']|&(?!([a-zA-Z]|(#\d)|(#[xX][\dA-Fa-f]));)/
      JSON_ESCAPE_REGEXP = /[\u2028\u2029&><]/u

      #Following XML requirements: https://www.w3.org/TR/REC-xml/#NT-Name
      TAG_NAME_START_REGEXP_SET = ":A-Z_a-z\u{C0}-\u{D6}\u{D8}-\u{F6}\u{F8}-\u{2FF}\u{370}-\u{37D}\u{37F}-\u{1FFF}" \
                                  "\u{200C}-\u{200D}\u{2070}-\u{218F}\u{2C00}-\u{2FEF}\u{3001}-\u{D7FF}\u{F900}-\u{FDCF}" \
                                  "\u{FDF0}-\u{FFFD}\u{10000}-\u{EFFFF}"
      TAG_NAME_START_REGEXP = /[^#{TAG_NAME_START_REGEXP_SET}]/
      TAG_NAME_FOLLOWING_REGEXP = /[^#{TAG_NAME_START_REGEXP_SET}\-.0-9\u{B7}\u{0300}-\u{036F}\u{203F}-\u{2040}]/
      TAG_NAME_REPLACEMENT_CHAR = "_"

      # A utility method for escaping XML names of tags and names of attributes.
      #
      #   xml_name_escape('1 < 2 & 3')
      #   # => "1___2___3"
      #
      # It follows the requirements of the specification: https://www.w3.org/TR/REC-xml/#NT-Name
      def xml_name_escape(name)
        name = name.to_s
        return "" if name.blank?

        starting_char = name[0].gsub(TAG_NAME_START_REGEXP, TAG_NAME_REPLACEMENT_CHAR)

        return starting_char if name.size == 1

        following_chars = name[1..-1].gsub(TAG_NAME_FOLLOWING_REGEXP, TAG_NAME_REPLACEMENT_CHAR)

        starting_char + following_chars
      end
      module_function :xml_name_escape
    end
  end
else
  puts "string output safety monkeypatch is no longer needed"
end

