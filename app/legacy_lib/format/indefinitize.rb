# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Format
  module Indefinitize
    VOWELS = %w[a e i o u].freeze

    def self.article(word)
      VOWELS.include?(word[0].downcase) ? "an" : "a"
    end

    def self.with_article(word)
      article(word) + " " + word
    end
  end
end
