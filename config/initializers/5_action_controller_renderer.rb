# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
if Rails.version < '5'
  # https://github.com/rails/rails/blob/801e399e42cab610860e307f2dd77c1edb6e1fac/actionpack/lib/action_controller/metal.rb
  module ActionController
    class Metal < AbstractController::Base
      def set_request!(request) #:nodoc:
        @_request = request
        @_env = request.env
        @_env['action_controller.instance'] = self
      end

      def set_custom_response!(response) # :nodoc:
        set_response!(response)
      end

      def self.make_response!(request)
        ActionDispatch::Response.new.tap do |res|
          res.request = request
        end
      end
      
    end
  end

  # from https://github.com/rails/rails/blob/801e399e42cab610860e307f2dd77c1edb6e1fac/actionpack/lib/action_controller/metal/rendering.rb
  module ActionController
    module Rendering
      module ClassMethods
        # Returns a renderer class (inherited from ActionController::Renderer)
        # for the controller.
        def renderer
          @renderer ||= Renderer.for(self)
        end
        delegate :render, to: :renderer

      end

    end
  end

  # from https://github.com/rails/rails/blob/eddb809b92808de50235a7975106ff974bee540f/actionpack/lib/action_controller/renderer.rb
  module ActionController
    # ActionController::Renderer allows you to render arbitrary templates
    # without requirement of being in controller actions.
    #
    # You get a concrete renderer class by invoking ActionController::Base#renderer.
    # For example:
    #
    #   ApplicationController.renderer
    #
    # It allows you to call method #render directly.
    #
    #   ApplicationController.renderer.render template: '...'
    #
    # You can use this shortcut in a controller, instead of the previous example:
    #
    #   ApplicationController.render template: '...'
    #
    # #render allows you to use the same options that you can use when rendering in a controller.
    # For example:
    #
    #   FooController.render :action, locals: { ... }, assigns: { ... }
    #
    # The template will be rendered in a Rack environment which is accessible through
    # ActionController::Renderer#env. You can set it up in two ways:
    #
    # *  by changing renderer defaults, like
    #
    #       ApplicationController.renderer.defaults # => hash with default Rack environment
    #
    # *  by initializing an instance of renderer by passing it a custom environment.
    #
    #       ApplicationController.renderer.new(method: 'post', https: true)
    #
    class Renderer
      attr_reader :defaults, :controller

      DEFAULTS = {
        http_host: "example.org",
        https: false,
        method: "get",
        script_name: "",
        input: ""
      }.freeze

      # Create a new renderer instance for a specific controller class.
      def self.for(controller, env = {}, defaults = DEFAULTS.dup)
        new(controller, env, defaults)
      end

      # Create a new renderer for the same controller but with a new env.
      def new(env = {})
        self.class.new controller, env, defaults
      end

      # Create a new renderer for the same controller but with new defaults.
      def with_defaults(defaults)
        self.class.new controller, @env, self.defaults.merge(defaults)
      end

      # Accepts a custom Rack environment to render templates in.
      # It will be merged with the default Rack environment defined by
      # +ActionController::Renderer::DEFAULTS+.
      def initialize(controller, env, defaults)
        @controller = controller
        @defaults = defaults
        @env = normalize_keys defaults, env
        @env['action_dispatch.routes'] = controller._routes
      end

      # Render templates with any options from ActionController::Base#render_to_string.
      #
      # The primary options are:
      # * <tt>:partial</tt> - See <tt>ActionView::PartialRenderer</tt> for details.
      # * <tt>:file</tt> - Renders an explicit template file. Add <tt>:locals</tt> to pass in, if so desired.
      #   It shouldn’t be used directly with unsanitized user input due to lack of validation.
      # * <tt>:inline</tt> - Renders an ERB template string.
      # * <tt>:plain</tt> - Renders provided text and sets the content type as <tt>text/plain</tt>.
      # * <tt>:html</tt> - Renders the provided HTML safe string, otherwise
      #   performs HTML escape on the string first. Sets the content type as <tt>text/html</tt>.
      # * <tt>:json</tt> - Renders the provided hash or object in JSON. You don't
      #   need to call <tt>.to_json</tt> on the object you want to render.
      # * <tt>:body</tt> - Renders provided text and sets content type of <tt>text/plain</tt>.
      #
      # If no <tt>options</tt> hash is passed or if <tt>:update</tt> is specified, then:
      #
      # If an object responding to +render_in+ is passed, +render_in+ is called on the object,
      # passing in the current view context.
      #
      # Otherwise, a partial is rendered using the second parameter as the locals hash.
      def render(*args)
        raise "missing controller" unless controller

        request = ActionDispatch::Request.new @env

        instance = controller.new
        instance.set_request! request
        instance.set_custom_response! request
        instance.render_to_string(*args)
      end
      alias_method :render_to_string, :render # :nodoc:

      private
        def normalize_keys(defaults, env)
          new_env = {}
          env.each_pair { |k, v| new_env[rack_key_for(k)] = rack_value_for(k, v) }

          defaults.each_pair do |k, v|
            key = rack_key_for(k)
            new_env[key] = rack_value_for(k, v) unless new_env.key?(key)
          end

          new_env["rack.url_scheme"] = new_env["HTTPS"] == "on" ? "https" : "http"
          new_env
        end

        RACK_KEY_TRANSLATION = {
          http_host:   "HTTP_HOST",
          https:       "HTTPS",
          method:      "REQUEST_METHOD",
          script_name: "SCRIPT_NAME",
          input:       "rack.input"
        }

        def rack_key_for(key)
          RACK_KEY_TRANSLATION[key] || key.to_s
        end

        def rack_value_for(key, value)
          case key
          when :https
            value ? "on" : "off"
          when :method
            -value.upcase
          else
            value
          end
        end
    end
  end

  # from https://github.com/rails/rails/blob/5-0-stable/actionview/lib/action_view/rendering.rb
  module ActionView
    module Rendering
      private 
      # Find and render a template based on the options given.
        # :api: private
      def _render_template(options) #:nodoc:
        variant = options.delete(:variant)
        assigns = options.delete(:assigns)
        context = view_context

        context.assign assigns if assigns
        lookup_context.rendered_format = nil if options[:formats]
        lookup_context.variants = variant if variant

        view_renderer.render(context, options)
      end
    end
  end
end

