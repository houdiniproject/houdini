# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'


# from https://github.com/rails/rails/blob/eddb809b92808de50235a7975106ff974bee540f/actionpack/test/controller/renderer_test.rb
describe ActionController::Renderer do


  FIXTURE_LOAD_PATH = File.join(File.dirname(__FILE__), '../fixtures/backport')
  FIXTURES = Pathname.new(FIXTURE_LOAD_PATH)
  

  before(:each) {
    @_original_path_set = ActionController::Base.view_paths
    ActionController::Base.view_paths = FIXTURE_LOAD_PATH
  
  


    stub_const("ApplicationController",
      Class.new(ActionController::Base) do 
      end)

    
    stub_const("ResourcesController", Class.new(ActionController::Base) do 
      def index() head :ok end
      alias_method :show, :index
    end)

    stub_const("CommentsController", Class.new(ResourcesController))
    stub_const("AccountsController", Class.new(ResourcesController))
    stub_const("ImagesController", Class.new(ResourcesController))

  }

  after(:each) {
    ActionController::Base.view_paths = @_original_path_set
  }
  it "action controller base has a renderer" do
    assert ActionController::Base.renderer
  end

  it "creating with a controller" do
    controller = CommentsController
    renderer   = ActionController::Renderer.for controller

    assert_equal controller, renderer.controller
  end

  it "creating from a controller" do
    controller = AccountsController
    renderer   = controller.renderer

    assert_equal controller, renderer.controller
  end

  it "creating with new defaults" do
    renderer = ApplicationController.renderer

    new_defaults = { https: true }
    new_renderer = renderer.with_defaults(new_defaults).new
    content = new_renderer.render(inline: "<%= request.ssl? %>")

    assert_equal "true", content
  end

  it "rendering with a class renderer" do
    renderer = ApplicationController.renderer
    content  = renderer.render template: "ruby_template"

    assert_equal "Hello from Ruby code", content
  end

  it "rendering with an instance renderer" do
    renderer = ApplicationController.renderer.new
    content  = renderer.render template: "test/hello_world"

    assert_equal "Hello world!", content
  end

  it "rendering with a controller class" do
    assert_equal "Hello world!", ApplicationController.render("test/hello_world")
  end

  it "rendering with locals" do
    renderer = ApplicationController.renderer
    content  = renderer.render template: "test/render_file_with_locals",
                               locals: { secret: "bar" }

    assert_equal "The secret is bar\n", content
  end

  
  it "rendering with assigns" do
    renderer = ApplicationController.renderer
    content  = renderer.render template: "test/render_file_with_ivar",
                               assigns: { secret: "foo" }

    assert_equal "The secret is foo\n", content
  end

  # We don't use this
  # it "render a renderable object" do
  #   renderer = ApplicationController.renderer

  #   assert_equal(
  #     %(Hello, World!),
  #     renderer.render(TestRenderable.new)
  #   )
  # end

  it "rendering with custom env" do
    renderer = ApplicationController.renderer.new method: "post"
    content  = renderer.render inline: "<%= request.post? %>"

    assert_equal "true", content
  end

  it "rendering with custom env using a key that is not in RACK_KEY_TRANSLATION" do
    value    = "warden is here"
    renderer = ApplicationController.renderer.new warden: value
    content  = renderer.render inline: "<%= request.env['warden'] %>"

    assert_equal value, content
  end

  it "rendering with defaults" do
    renderer = ApplicationController.renderer.new https: true
    content = renderer.render inline: "<%= request.ssl? %>"

    assert_equal "true", content
  end

  it "same defaults from the same controller" do
    renderer_defaults = ->(controller) { controller.renderer.defaults }

    assert_equal renderer_defaults[AccountsController], renderer_defaults[AccountsController]
    assert_equal renderer_defaults[AccountsController], renderer_defaults[CommentsController]
  end

  it "rendering with different formats" do
    html = "Hello world!"
    xml  = "<p>Hello world!</p>\n"

    assert_equal html, render["respond_to/using_defaults"]
    assert_equal xml,  render["respond_to/using_defaults.xml.builder"] 
    assert_equal xml,  render["respond_to/using_defaults", formats: :xml]
  end

  it "rendering with helpers" do
    assert_equal "<p>1\n<br />2</p>", render[inline: '<%= simple_format "1\n2" %>']
  end

  it "rendering with user specified defaults" do
    ApplicationController.renderer.defaults.merge!(hello: "hello", https: true)
    renderer = ApplicationController.renderer.new
    content = renderer.render inline: "<%= request.ssl? %>"

    assert_equal "true", content
  end

  it "return valid asset URL with defaults" do
    renderer = ApplicationController.renderer
    content  = renderer.render inline: "<%= asset_url 'asset.jpg' %>"

    assert_equal "http://example.org/asset.jpg", content
  end

  it "return valid asset URL when https is true" do
    renderer = ApplicationController.renderer.new https: true
    content  = renderer.render inline: "<%= asset_url 'asset.jpg' %>"

    assert_equal "https://example.org/asset.jpg", content
  end

  private
    def render
      @render ||= ApplicationController.renderer.method(:render)
    end
end