# from https://github.com/rails/rails/blob/0ecaaf76d1b79cf2717cdac754e55b4114ad6599/activesupport/lib/active_support/inflector/methods.rb

# Rails version listed in https://github.com/advisories/GHSA-j6gc-792m-qgm2
if Rails.version < '6.1'
  require 'active_support/inflector/methods'

  module ActiveSupport
    # The Inflector transforms words from singular to plural, class names to table
    # names, modularized class names to ones without, and class names to foreign
    # keys. The default inflections for pluralization, singularization, and
    # uncountable words are kept in inflections.rb.
    #
    # The Rails core team has stated patches for the inflections library will not
    # be accepted in order to avoid breaking legacy applications which may be
    # relying on errant inflections. If you discover an incorrect inflection and
    # require it for your application or wish to define rules for languages other
    # than English, please correct or add them yourself (explained below).
    module Inflector
      extend self
       
      def underscore(camel_cased_word)
        return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
        word = camel_cased_word.to_s.gsub(/::/, '/')
        word.gsub!(inflections.acronyms_underscore_regex) { "#{$1 && '_' }#{$2.downcase}" }
        word.gsub!(/([A-Z])(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) { ($1 || $2) << "_" }
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end
  end
else
  puts "tag helper monkeypatch no longer needed"
end
