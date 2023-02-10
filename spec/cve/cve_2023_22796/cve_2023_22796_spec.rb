# from https://github.com/rails/rails/blob/0ecaaf76d1b79cf2717cdac754e55b4114ad6599/activesupport/test/inflector_test.rb#L4
require 'rails_helper'

describe 'inflector test' do

  require_relative './inflector_test_cases'
  around(:each) do |example|
    with_dup do
      example.run
    end
  end

  # from https://github.com/rails/rails/blob/0ecaaf76d1b79cf2717cdac754e55b4114ad6599/activesupport/test/inflector_test.rb#L524-L536
  # Dups the singleton and yields, restoring the original inflections later.
  # Use this in tests what modify the state of the singleton.
  #
  # This helper is implemented by setting @__instance__ because in some tests
  # there are module functions that access ActiveSupport::Inflector.inflections,
  # so we need to replace the singleton itself.
  def with_dup
    original = ActiveSupport::Inflector::Inflections.instance_variable_get(:@__instance__)[:en]
    ActiveSupport::Inflector::Inflections.instance_variable_set(:@__instance__, en: original.dup)
    yield
  ensure
    ActiveSupport::Inflector::Inflections.instance_variable_set(:@__instance__, en: original)
  end
  
  it 'handles acronyms' do 
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("HTML")
      inflect.acronym("HTTP")
      inflect.acronym("RESTful")
      inflect.acronym("W3C")
      inflect.acronym("PhD")
      inflect.acronym("RoR")
      inflect.acronym("SSL")
    end

    #  camelize             underscore            humanize              titleize
    [
      ["API",               "api",                "API",                "API"],
      ["APIController",     "api_controller",     "API controller",     "API Controller"],
      ["Nokogiri::HTML",    "nokogiri/html",      "Nokogiri/HTML",      "Nokogiri/HTML"],
      ["HTTPAPI",           "http_api",           "HTTP API",           "HTTP API"],
      ["HTTP::Get",         "http/get",           "HTTP/get",           "HTTP/Get"],
      ["SSLError",          "ssl_error",          "SSL error",          "SSL Error"],
      ["RESTful",           "restful",            "RESTful",            "RESTful"],
      ["RESTfulController", "restful_controller", "RESTful controller", "RESTful Controller"],
      ["Nested::RESTful",   "nested/restful",     "Nested/RESTful",     "Nested/RESTful"],
      ["IHeartW3C",         "i_heart_w3c",        "I heart W3C",        "I Heart W3C"],
      ["PhDRequired",       "phd_required",       "PhD required",       "PhD Required"],
      ["IRoRU",             "i_ror_u",            "I RoR u",            "I RoR U"],
      ["RESTfulHTTPAPI",    "restful_http_api",   "RESTful HTTP API",   "RESTful HTTP API"],
      ["HTTP::RESTful",     "http/restful",       "HTTP/RESTful",       "HTTP/RESTful"],
      ["HTTP::RESTfulAPI",  "http/restful_api",   "HTTP/RESTful API",   "HTTP/RESTful API"],
      ["APIRESTful",        "api_restful",        "API RESTful",        "API RESTful"],

      # misdirection
      ["Capistrano",        "capistrano",         "Capistrano",       "Capistrano"],
      ["CapiController",    "capi_controller",    "Capi controller",  "Capi Controller"],
      ["HttpsApis",         "https_apis",         "Https apis",       "Https Apis"],
      ["Html5",             "html5",              "Html5",            "Html5"],
      ["Restfully",         "restfully",          "Restfully",        "Restfully"],
      ["RoRails",           "ro_rails",           "Ro rails",         "Ro Rails"]
    ].each do |camel, under, human, title|
      assert_equal(camel, ActiveSupport::Inflector.camelize(under))
      assert_equal(camel, ActiveSupport::Inflector.camelize(camel))
      assert_equal(under, ActiveSupport::Inflector.underscore(under))
      assert_equal(under, ActiveSupport::Inflector.underscore(camel))
      assert_equal(title, ActiveSupport::Inflector.titleize(under))
      assert_equal(title, ActiveSupport::Inflector.titleize(camel))
      assert_equal(human, ActiveSupport::Inflector.humanize(under))
    end
  end

  it 'handles underscores' do
    InflectorTestCases::CamelToUnderscore.each do |camel, underscore|
      assert_equal(underscore, ActiveSupport::Inflector.underscore(camel))
    end
    InflectorTestCases::CamelToUnderscoreWithoutReverse.each do |camel, underscore|
      assert_equal(underscore, ActiveSupport::Inflector.underscore(camel))
    end
  end

  it 'handles underscore with slashes' do
    InflectorTestCases::CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      assert_equal(underscore, ActiveSupport::Inflector.underscore(camel))
    end
  end

  it 'handles underscore as reverse of dasherize' do
    InflectorTestCases::UnderscoresToDashes.each_key do |underscored|
      assert_equal(underscored, ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.dasherize(underscored)))
    end
  end
end
