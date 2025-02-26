
# related to this issue https://discuss.rubyonrails.org/t/cve-2022-27777-possible-xss-vulnerability-in-action-view-tag-helpers/80534
if Rails.version < '5.2'
  require 'action_view/helpers/tag_helper'

  module ActionView
    # = Action View Tag Helpers
    module Helpers # :nodoc:
      # Provides methods to generate HTML tags programmatically both as a modern
      # HTML5 compliant builder style and legacy XHTML compliant tags.
      module TagHelper
        class TagBuilder
          def tag_string(name, content = nil, **options, &block)
            escape = handle_deprecated_escape_options(options)
            content = @view_context.capture(self, &block) if block_given?
            
            if VOID_ELEMENTS.include?(name) && content.nil?
              "<#{name.to_s.dasherize}#{tag_options(options, escape)}>".html_safe
                       else
            
              content_tag_string(name.to_s.dasherize, content || "", options, escape)
              
            end
          end

          def content_tag_string(name, content, options, escape = true)
            tag_options = tag_options(options, escape) if options
            if escape
              name = ERB::Util.xml_name_escape(name)
              content = ERB::Util.unwrapped_html_escape(content)
            end
            
            "<#{name}#{tag_options}>#{PRE_CONTENT_STRINGS[name]}#{content}</#{name}>".html_safe
          end

          def tag_option(key, value, escape)
            key = ERB::Util.xml_name_escape(key) if escape
  
            if value.is_a?(Array)
              value = escape ? safe_join(value, " ") : value.join(" ")
            elsif value.is_a? Regexp
              value = escape ? ERB::Util.unwrapped_html_escape(value.source) : value.source
            else
              value = escape ? ERB::Util.unwrapped_html_escape(value) : value.to_s
            end
            %(#{key}="#{value.gsub('"'.freeze, '&quot;'.freeze)}")
          end

          def handle_deprecated_escape_options(options)
            # The option :escape_attributes has been merged into the options hash to be
            # able to warn when it is used, so we need to handle default values here.
            escape_option_provided = options.has_key?(:escape)
            escape_attributes_option_provided = options.has_key?(:escape_attributes)

            if escape_attributes_option_provided
              ActiveSupport::Deprecation.warn(<<~MSG)
                Use of the option :escape_attributes is deprecated. It currently \
                escapes both names and values of tags and attributes and it is \
                equivalent to :escape. If any of them are enabled, the escaping \
                is fully enabled.
              MSG
            end

            return true unless escape_option_provided || escape_attributes_option_provided
            escape_option = options.delete(:escape)
            escape_attributes_option = options.delete(:escape_attributes)
            escape_option || escape_attributes_option
          end

          def method_missing(called, *args, **options, &block)
            tag_string(called, *args, **options, &block)
          end
        end
                    # Returns an HTML tag.
        #
        # === Building HTML tags
        #
        # Builds HTML5 compliant tags with a tag proxy. Every tag can be built with:
        #
        #   tag.<tag name>(optional content, options)
        #
        # where tag name can be e.g. br, div, section, article, or any tag really.
        #
        # ==== Passing content
        #
        # Tags can pass content to embed within it:
        #
        #   tag.h1 'All titles fit to print' # => <h1>All titles fit to print</h1>
        #
        #   tag.div tag.p('Hello world!')  # => <div><p>Hello world!</p></div>
        #
        # Content can also be captured with a block, which is useful in templates:
        #
        #   <%= tag.p do %>
        #     The next great American novel starts here.
        #   <% end %>
        #   # => <p>The next great American novel starts here.</p>
        #
        # ==== Options
        #
        # Use symbol keyed options to add attributes to the generated tag.
        #
        #   tag.section class: %w( kitties puppies )
        #   # => <section class="kitties puppies"></section>
        #
        #   tag.section id: dom_id(@post)
        #   # => <section id="<generated dom id>"></section>
        #
        # Pass +true+ for any attributes that can render with no values, like +disabled+ and +readonly+.
        #
        #   tag.input type: 'text', disabled: true
        #   # => <input type="text" disabled="disabled">
        #
        # HTML5 <tt>data-*</tt> and <tt>aria-*</tt> attributes can be set with a
        # single +data+ or +aria+ key pointing to a hash of sub-attributes.
        #
        # To play nicely with JavaScript conventions, sub-attributes are dasherized.
        #
        #   tag.article data: { user_id: 123 }
        #   # => <article data-user-id="123"></article>
        #
        # Thus <tt>data-user-id</tt> can be accessed as <tt>dataset.userId</tt>.
        #
        # Data attribute values are encoded to JSON, with the exception of strings, symbols, and
        # BigDecimals.
        # This may come in handy when using jQuery's HTML5-aware <tt>.data()</tt>
        # from 1.4.3.
        #
        #   tag.div data: { city_state: %w( Chicago IL ) }
        #   # => <div data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]"></div>
        #
        # The generated tag names and attributes are escaped by default. This can be disabled using
        # +escape+.
        #
        #   tag.img src: 'open & shut.png'
        #   # => <img src="open &amp; shut.png">
        #
        #   tag.img src: 'open & shut.png', escape: false
        #   # => <img src="open & shut.png">
        #
        # The tag builder respects
        # {HTML5 void elements}[https://www.w3.org/TR/html5/syntax.html#void-elements]
        # if no content is passed, and omits closing tags for those elements.
        #
        #   # A standard element:
        #   tag.div # => <div></div>
        #
        #   # A void element:
        #   tag.br  # => <br>
        #
        # === Building HTML attributes
        #
        # Transforms a Hash into HTML attributes, ready to be interpolated into
        # ERB. Includes or omits boolean attributes based on their truthiness.
        # Transforms keys nested within
        # <tt>aria:</tt> or <tt>data:</tt> objects into <tt>aria-</tt> and <tt>data-</tt>
        # prefixed attributes:
        #
        #   <input <%= tag.attributes(type: :text, aria: { label: "Search" }) %>>
        #   # => <input type="text" aria-label="Search">
        #
        #   <button <%= tag.attributes id: "call-to-action", disabled: false, aria: { expanded: false } %> class="primary">Get Started!</button>
        #   # => <button id="call-to-action" aria-expanded="false" class="primary">Get Started!</button>
        #
        # === Legacy syntax
        #
        # The following format is for legacy syntax support. It will be deprecated in future versions of Rails.
        #
        #   tag(name, options = nil, open = false, escape = true)
        #
        # It returns an empty HTML tag of type +name+ which by default is XHTML
        # compliant. Set +open+ to true to create an open tag compatible
        # with HTML 4.0 and below. Add HTML attributes by passing an attributes
        # hash to +options+. Set +escape+ to false to disable attribute value
        # escaping.
        #
        # ==== Options
        #
        # You can use symbols or strings for the attribute names.
        #
        # Use +true+ with boolean attributes that can render with no value, like
        # +disabled+ and +readonly+.
        #
        # HTML5 <tt>data-*</tt> attributes can be set with a single +data+ key
        # pointing to a hash of sub-attributes.
        #
        # ==== Examples
        #
        #   tag("br")
        #   # => <br />
        #
        #   tag("br", nil, true)
        #   # => <br>
        #
        #   tag("input", type: 'text', disabled: true)
        #   # => <input type="text" disabled="disabled" />
        #
        #   tag("input", type: 'text', class: ["strong", "highlight"])
        #   # => <input class="strong highlight" type="text" />
        #
        #   tag("img", src: "open & shut.png")
        #   # => <img src="open &amp; shut.png" />
        #
        #   tag("img", { src: "open &amp; shut.png" }, false, false)
        #   # => <img src="open &amp; shut.png" />
        #
        #   tag("div", data: { name: 'Stephen', city_state: %w(Chicago IL) })
        #   # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
        #
        #   tag("div", class: { highlight: current_user.admin? })
        #   # => <div class="highlight" />
        def tag(name = nil, options = nil, open = false, escape = true)
          if name.nil?
            tag_builder
          else
            name = ERB::Util.xml_name_escape(name) if escape
            "<#{name}#{tag_builder.tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
          end
        end
      end
    end
  end
else
  puts "tag helper monkeypatch no longer needed"
end
