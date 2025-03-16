# from https://github.com/rails/rails/blob/0ecaaf76d1b79cf2717cdac754e55b4114ad6599/actionpack/test/dispatch/cookies_test.rb
# and from https://github.com/rails/rails/blob/daa00c8357dc12ce24f89d92e4ceeabebb3af3d1/actionpack/test/dispatch/cookies_test.rb
# and from https://github.com/rails/rails/blob/663206d20aec374a28a24bb43bc7b1233042ed9b/actionpack/test/dispatch/cookies_test.rb
require 'rails_helper'

require "openssl"
require "active_support/key_generator"
require "active_support/message_verifier"

describe 'CookieJarTest' do
  
  include Minitest::Assertions
  include ActiveSupport::Testing::Assertions

  attr_reader :request

  before(:each) do
    @request = ActionDispatch::Request.empty
  end

  it "test_fetch" do
    x = Object.new
    assert_not request.cookie_jar.key?("zzzzzz")
    assert_equal x, request.cookie_jar.fetch("zzzzzz", x)
    assert_not request.cookie_jar.key?("zzzzzz")
  end

  it "test_fetch_exists" do
    x = Object.new
    request.cookie_jar["foo"] = "bar"
    assert_equal "bar", request.cookie_jar.fetch("foo", x)
  end

  it "test_fetch_block" do
    x = Object.new
    assert_not request.cookie_jar.key?("zzzzzz")
    assert_equal x, request.cookie_jar.fetch("zzzzzz") { x }
  end

  it "test_key_is_to_s" do
    request.cookie_jar["foo"] = "bar"
    assert_equal "bar", request.cookie_jar.fetch(:foo)
  end

  it "test_fetch_type_error" do
    assert_raises(KeyError) do
      request.cookie_jar.fetch(:omglolwut)
    end
  end

  it "test_each" do
    request.cookie_jar["foo"] = :bar
    list = []
    request.cookie_jar.each do |k, v|
      list << [k, v]
    end

    assert_equal [["foo", :bar]], list
  end

  it "test_enumerable" do
    request.cookie_jar["foo"] = :bar
    actual = request.cookie_jar.map { |k, v| [k.to_s, v.to_s] }
    assert_equal [["foo", "bar"]], actual
  end

  it "test_key_methods" do
    assert !request.cookie_jar.key?(:foo)
    assert !request.cookie_jar.has_key?("foo")

    request.cookie_jar[:foo] = :bar
    assert request.cookie_jar.key?(:foo)
    assert request.cookie_jar.has_key?("foo")
  end

  it "test_write_doesnt_set_a_nil_header" do
    headers = {}
    request.cookie_jar.write(headers)
    assert_nil headers["Set-Cookie"]
  end
end

class TestController < ActionController::Base
  def authenticate
    cookies["user_name"] = "david"
    head :ok
  end

  def set_with_with_escapable_characters
    cookies["that & guy"] = "foo & bar => baz"
    head :ok
  end

  def authenticate_for_fourteen_days
    cookies["user_name"] = { "value" => "david", "expires" => Time.utc(2005, 10, 10, 5) }
    head :ok
  end

  def authenticate_for_fourteen_days_with_symbols
    cookies[:user_name] = { value: "david", expires: Time.utc(2005, 10, 10, 5) }
    head :ok
  end

  def set_multiple_cookies
    cookies["user_name"] = { "value" => "david", "expires" => Time.utc(2005, 10, 10, 5) }
    cookies["login"]     = "XJ-122"
    head :ok
  end

  def access_frozen_cookies
    cookies["will"] = "work"
    head :ok
  end

  def logout
    cookies.delete("user_name")
    head :ok
  end

  alias delete_cookie logout

  def delete_cookie_with_path
    cookies.delete("user_name", path: "/beaten")
    head :ok
  end

  def authenticate_with_http_only
    cookies["user_name"] = { value: "david", httponly: true }
    head :ok
  end

  def authenticate_with_secure
    cookies["user_name"] = { value: "david", secure: true }
    head :ok
  end

  def set_permanent_cookie
    cookies.permanent[:user_name] = "Jamie"
    head :ok
  end

  def set_signed_cookie
    cookies.signed[:user_id] = 45
    head :ok
  end

  def get_signed_cookie
    cookies.signed[:user_id]
    head :ok
  end

  def set_encrypted_cookie
    cookies.encrypted[:foo] = "bar"
    head :ok
  end

  def set_wrapped_signed_cookie
    cookies.signed[:user_id] = JSONWrapper.new(45)
    head :ok
  end

  def set_wrapped_encrypted_cookie
    cookies.encrypted[:foo] = JSONWrapper.new("bar")
    head :ok
  end

  def get_encrypted_cookie
    cookies.encrypted[:foo]
    head :ok
  end

  def set_invalid_encrypted_cookie
    cookies[:invalid_cookie] = "invalid--9170e00a57cfc27083363b5c75b835e477bd90cf"
    head :ok
  end

  def raise_data_overflow
    cookies.signed[:foo] = "bye!" * 1024
    head :ok
  end

  def tampered_cookies
    cookies[:tampered] = "BAh7BjoIZm9vIghiYXI%3D--123456780"
    cookies.signed[:tampered]
    head :ok
  end

  def set_permanent_signed_cookie
    cookies.permanent.signed[:remember_me] = 100
    head :ok
  end

  def delete_and_set_cookie
    cookies.delete :user_name
    cookies[:user_name] = { value: "david", expires: Time.utc(2005, 10, 10, 5) }
    head :ok
  end

  def set_cookie_with_domain
    cookies[:user_name] = { value: "rizwanreza", domain: :all }
    head :ok
  end

  def set_cookie_with_domain_all_as_string
    cookies[:user_name] = { value: "rizwanreza", domain: "all" }
    head :ok
  end

  def delete_cookie_with_domain
    cookies.delete(:user_name, domain: :all)
    head :ok
  end

  def delete_cookie_with_domain_all_as_string
    cookies.delete(:user_name, domain: "all")
    head :ok
  end

  def set_cookie_with_domain_and_longer_tld
    cookies[:user_name] = { value: "rizwanreza", domain: :all, tld_length: 4 }
    head :ok 
  end

  def set_cookie_with_domain_and_tld
    cookies[:user_name] = { value: "rizwanreza", domain: :all, tld_length: 2 }
    head :ok
  end

  def delete_cookie_with_domain_and_tld
    cookies.delete(:user_name, domain: :all, tld_length: 2)
    head :ok
  end

  def set_cookie_with_domains
    cookies[:user_name] = { value: "rizwanreza", domain: %w(example1.com example2.com .example3.com) }
    head :ok
  end

  def delete_cookie_with_domains
    cookies.delete(:user_name, domain: %w(example1.com example2.com .example3.com))
    head :ok
  end

  def symbol_key
    cookies[:user_name] = "david"
    head :ok
  end

  def string_key
    cookies["user_name"] = "dhh"
    head :ok
  end

  def symbol_key_mock
    cookies[:user_name] = "david" if cookies[:user_name] == "andrew"
    head :ok
  end

  def string_key_mock
    cookies["user_name"] = "david" if cookies["user_name"] == "andrew"
    head :ok
  end

  def noop
    head :ok
  end

  def encrypted_cookie
    cookies.encrypted["foo"]
  end
end

describe TestController, type: :controller do

  include Minitest::Assertions
  include ActiveSupport::Testing::Assertions

  around(:each) do |example|
    old_serializers = Rails.application.config.action_dispatch.cookies_serializer

    Rails.application.config.action_dispatch.cookies_serializer = :marshal
    example.run

    Rails.application.config.action_dispatch.cookies_serializer = old_serializers
  end

  routes do  
    ActionDispatch::Routing::RouteSet.new.tap  do |set|
      set.draw do 
        get ':controller(/:action)'
      end
    end
  end

  class CustomSerializer
    def self.load(value)
      value.to_s + " and loaded"
    end

    def self.dump(value)
      value.to_s + " was dumped"
    end
  end

  class JSONWrapper
    def initialize(obj)
      @obj = obj
    end

    def as_json(options = nil)
      "wrapped: #{@obj.as_json(options)}"
    end
  end


  tests TestController

  SALT = "b3c631c314c0bbca50c1b2843150fe33"

  before(:each) do 
    @controller = TestController.new

    @request.env["action_dispatch.key_generator"] = ActiveSupport::KeyGenerator.new(SALT, iterations: 2)

    @request.env["action_dispatch.signed_cookie_salt"] =
      @request.env["action_dispatch.encrypted_cookie_salt"] =
      @request.env["action_dispatch.encrypted_signed_cookie_salt"] = SALT

    @request.host = "www.nextangle.com"
  end

  it "test_setting_cookie" do
    get :authenticate
    assert_cookie_header "user_name=david; path=/"
    assert_equal({ "user_name" => "david" }, @response.cookies)
  end

  it "test_setting_the_same_value_to_cookie" do
    request.cookies[:user_name] = "david"
    get :authenticate
    assert_predicate response.cookies, :empty?
  end

  it "test_setting_the_same_value_to_permanent_cookie" do
    request.cookies[:user_name] = "Jamie"
    get :set_permanent_cookie
    assert_equal({ "user_name" => "Jamie" }, response.cookies)
  end

  it "test_setting_with_escapable_characters" do
    get :set_with_with_escapable_characters
    assert_cookie_header "that+%26+guy=foo+%26+bar+%3D%3E+baz; path=/"
    assert_equal({ "that & guy" => "foo & bar => baz" }, @response.cookies)
  end

  it "test_setting_cookie_for_fourteen_days" do
    get :authenticate_for_fourteen_days
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10 Oct 2005 05:00:00 GMT"
    assert_equal({ "user_name" => "david" }, @response.cookies)
  end

  it "test_setting_cookie_for_fourteen_days_with_symbols" do
    get :authenticate_for_fourteen_days_with_symbols
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10 Oct 2005 05:00:00 GMT"
    assert_equal({ "user_name" => "david" }, @response.cookies)
  end

  it "test_setting_cookie_with_http_only" do
    get :authenticate_with_http_only
    assert_cookie_header "user_name=david; path=/; HttpOnly"
    assert_equal({ "user_name" => "david" }, @response.cookies)
  end

  it "test_setting_cookie_with_secure" do
    @request.env["HTTPS"] = "on"
    get :authenticate_with_secure
    assert_cookie_header "user_name=david; path=/; secure"
    assert_equal({ "user_name" => "david" }, @response.cookies)
  end

  it "test_setting_cookie_with_secure_when_always_write_cookie_is_true" do
    old_cookie, @request.cookie_jar.always_write_cookie = @request.cookie_jar.always_write_cookie, true
    get :authenticate_with_secure
    assert_cookie_header "user_name=david; path=/; secure"
    assert_equal({ "user_name" => "david" }, @response.cookies)
  ensure
    @request.cookie_jar.always_write_cookie = old_cookie
  end

  it "test_not_setting_cookie_with_secure" do
    get :authenticate_with_secure
    assert_not_cookie_header "user_name=david; path=/; secure"
    expect({"user_name" => "david"}).to_not eq @response.cookies
  end

  it "test_multiple_cookies" do
    get :set_multiple_cookies
    assert_equal 2, @response.cookies.size
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10 Oct 2005 05:00:00 GMT\nlogin=XJ-122; path=/"
    assert_equal({ "login" => "XJ-122", "user_name" => "david" }, @response.cookies)
  end

  it "test_setting_test_cookie" do
    assert_nothing_raised { get :access_frozen_cookies }
  end

  it "test_expiring_cookie" do
    request.cookies[:user_name] = "Joe"
    get :logout
    assert_cookie_header "user_name=; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
    assert_equal({ "user_name" => nil }, @response.cookies)
  end

  it "test_delete_cookie_with_path" do
    request.cookies[:user_name] = "Joe"
    get :delete_cookie_with_path
    assert_cookie_header "user_name=; path=/beaten; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
  end

  it "test_delete_unexisting_cookie" do
    request.cookies.clear
    get :delete_cookie
    assert_predicate @response.cookies, :empty?
  end

  it "test_deleted_cookie_predicate" do
    cookies[:user_name] = "Joe"
    cookies.delete("user_name")
    assert cookies.deleted?("user_name")
    assert_equal false, cookies.deleted?("another")
  end

  it "test_deleted_cookie_predicate_with_mismatching_options" do
    cookies[:user_name] = "Joe"
    cookies.delete("user_name", path: "/path")
    assert_equal false, cookies.deleted?("user_name", path: "/different")
  end

  it "test_cookies_persist_throughout_request" do
    response = get :authenticate
    assert_match(/user_name=david/, response.headers["Set-Cookie"])
  end

  it "test_set_permanent_cookie" do
    get :set_permanent_cookie
    assert_match(/Jamie/, @response.headers["Set-Cookie"])
    assert_match(%r(#{20.years.from_now.utc.year}), @response.headers["Set-Cookie"])
  end

  it "test_read_permanent_cookie" do
    get :set_permanent_cookie
    assert_equal "Jamie", @controller.send(:cookies).permanent[:user_name]
  end

  it "test_signed_cookie_using_default_digest" do
    get :set_signed_cookie
    cookies = @controller.send :cookies
    expect(45).to_not eq cookies[:user_id]
    assert_equal 45, cookies.signed[:user_id]

    key_generator = @request.env["action_dispatch.key_generator"]
    signed_cookie_salt = @request.env["action_dispatch.signed_cookie_salt"]
    secret = key_generator.generate_key(signed_cookie_salt)

    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: Marshal, digest: "SHA1")
    assert_equal verifier.generate(45), cookies[:user_id]
  end

  it "test_signed_cookie_using_custom_digest" do
    @request.env["action_dispatch.cookies_digest"] = "SHA256"
    get :set_signed_cookie
    cookies = @controller.send :cookies
    expect(45).to_not eq cookies[:user_id]
    assert_equal 45, cookies.signed[:user_id]

    key_generator = @request.env["action_dispatch.key_generator"]
    signed_cookie_salt = @request.env["action_dispatch.signed_cookie_salt"]
    secret = key_generator.generate_key(signed_cookie_salt)

    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: Marshal, digest: "SHA256")
    assert_equal verifier.generate(45), cookies[:user_id]
  end

  it "test_signed_cookie_using_default_serializer" do
    get :set_signed_cookie
    cookies = @controller.send :cookies
    expect(45).to_not eq cookies[:user_id]
    assert_equal 45, cookies.signed[:user_id]
  end

  it "test_signed_cookie_using_marshal_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = :marshal
    get :set_signed_cookie
    cookies = @controller.send :cookies
    expect(45).to_not eq cookies[:user_id]
    assert_equal 45, cookies.signed[:user_id]
  end

  it "test_signed_cookie_using_json_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = :json
    get :set_signed_cookie
    cookies = @controller.send :cookies
    expect(45).to_not eq cookies[:user_id]
    assert_equal 45, cookies.signed[:user_id]
  end

  it "test_wrapped_signed_cookie_using_json_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = :json
    get :set_wrapped_signed_cookie
    cookies = @controller.send :cookies
    expect('wrapped: 45').to_not eq cookies[:user_id]
    assert_equal 'wrapped: 45', cookies.signed[:user_id]
  end

  it "test_signed_cookie_using_custom_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = CustomSerializer
    get :set_signed_cookie
    expect(45).to_not eq cookies[:user_id]
    assert_equal '45 was dumped and loaded', cookies.signed[:user_id]
  end

  it "test_signed_cookie_using_hybrid_serializer_can_migrate_marshal_dumped_value_to_json" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid

    key_generator = @request.env["action_dispatch.key_generator"]
    signed_cookie_salt = @request.env["action_dispatch.signed_cookie_salt"]
    secret = key_generator.generate_key(signed_cookie_salt)

    marshal_value = ActiveSupport::MessageVerifier.new(secret, serializer: Marshal).generate(45)
    @request.headers["Cookie"] = "user_id=#{marshal_value}"

    get :get_signed_cookie

    cookies = @controller.send :cookies
    expect(45).to_not eq cookies[:user_id]
    assert_equal 45, cookies.signed[:user_id]

    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON)
    assert_equal 45, verifier.verify(@response.cookies['user_id'])
  end

  it "test_signed_cookie_using_hybrid_serializer_can_read_from_json_dumped_value" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid

    key_generator = @request.env["action_dispatch.key_generator"]
    signed_cookie_salt = @request.env["action_dispatch.signed_cookie_salt"]
    secret = key_generator.generate_key(signed_cookie_salt)
    json_value = ActiveSupport::MessageVerifier.new(secret, serializer: JSON).generate(45)
    @request.headers["Cookie"] = "user_id=#{json_value}"

    get :get_signed_cookie

    cookies = @controller.send :cookies
    expect(45).to_not eq cookies[:user_id]
    assert_equal 45, cookies.signed[:user_id]

    assert_nil @response.cookies["user_id"]
  end

  it "test_accessing_nonexistant_signed_cookie_should_not_raise_an_invalid_signature" do
    get :set_signed_cookie
    assert_nil @controller.send(:cookies).signed[:non_existant_attribute]
  end

  it "test_encrypted_cookie_using_default_serializer" do
    get :set_encrypted_cookie
    cookies = @controller.send :cookies
    expect('bar').to_not eq cookies[:foo]
    assert_raises TypeError do
      cookies.signed[:foo]
    end
    assert_equal "bar", cookies.encrypted[:foo]
  end

  it "test_encrypted_cookie_using_marshal_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = :marshal
    get :set_encrypted_cookie
    cookies = @controller.send :cookies
    expect('bar').to_not eq cookies[:foo]
    assert_raises TypeError do
      cookies.signed[:foo]
    end
    assert_equal "bar", cookies.encrypted[:foo]
  end

  it "test_encrypted_cookie_using_json_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = :json
    get :set_encrypted_cookie
    cookies = @controller.send :cookies
    expect('bar').to_not eq cookies[:foo]
    assert_raises ::JSON::ParserError do
      cookies.signed[:foo]
    end
    assert_equal "bar", cookies.encrypted[:foo]
  end

  it "test_wrapped_encrypted_cookie_using_json_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = :json
    get :set_wrapped_encrypted_cookie
    cookies = @controller.send :cookies
    expect('wrapped: bar').to_not eq cookies[:foo]
    assert_raises ::JSON::ParserError do
      cookies.signed[:foo]
    end
    assert_equal "wrapped: bar", cookies.encrypted[:foo]
  end

  it "test_encrypted_cookie_using_custom_serializer" do
    @request.env["action_dispatch.cookies_serializer"] = CustomSerializer
    get :set_encrypted_cookie
    expect('bar').to_not eq cookies.encrypted[:foo]
    assert_equal 'bar was dumped and loaded', cookies.encrypted[:foo]
  end

  it "test_encrypted_cookie_using_custom_digest" do
    @request.env["action_dispatch.cookies_digest"] = "SHA256"
    get :set_encrypted_cookie
    cookies = @controller.send :cookies
    expect('bar').to_not eq cookies[:foo]
    assert_equal 'bar', cookies.encrypted[:foo]

    sign_secret = @request.env["action_dispatch.key_generator"].generate_key(@request.env["action_dispatch.encrypted_signed_cookie_salt"])

    sha1_verifier   = ActiveSupport::MessageVerifier.new(sign_secret, serializer: ActiveSupport::MessageEncryptor::NullSerializer, digest: "SHA1")
    sha256_verifier = ActiveSupport::MessageVerifier.new(sign_secret, serializer: ActiveSupport::MessageEncryptor::NullSerializer, digest: "SHA256")

    assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
      sha1_verifier.verify(cookies[:foo])
    end

    assert_nothing_raised do
      sha256_verifier.verify(cookies[:foo])
    end
  end

  it "test_encrypted_cookie_using_hybrid_serializer_can_migrate_marshal_dumped_value_to_json" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid

    key_generator = @request.env["action_dispatch.key_generator"]
    encrypted_cookie_salt = @request.env["action_dispatch.encrypted_cookie_salt"]
    encrypted_signed_cookie_salt = @request.env["action_dispatch.encrypted_signed_cookie_salt"]
    secret = key_generator.generate_key(encrypted_cookie_salt)
    sign_secret = key_generator.generate_key(encrypted_signed_cookie_salt)

    marshal_value = ActiveSupport::MessageEncryptor.new(secret[0, ActiveSupport::MessageEncryptor.key_len], sign_secret, serializer: Marshal).encrypt_and_sign("bar")
    @request.headers["Cookie"] = "foo=#{marshal_value}"

    get :get_encrypted_cookie

    cookies = @controller.send :cookies
    expect("bar").to_not eq cookies[:foo]
    assert_equal "bar", cookies.encrypted[:foo]

    encryptor = ActiveSupport::MessageEncryptor.new(secret[0, ActiveSupport::MessageEncryptor.key_len], sign_secret, serializer: JSON)
    assert_equal "bar", encryptor.decrypt_and_verify(@response.cookies["foo"])
  end

  it "test_encrypted_cookie_using_hybrid_serializer_can_read_from_json_dumped_value" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid

    key_generator = @request.env["action_dispatch.key_generator"]
    encrypted_cookie_salt = @request.env["action_dispatch.encrypted_cookie_salt"]
    encrypted_signed_cookie_salt = @request.env["action_dispatch.encrypted_signed_cookie_salt"]
    secret = key_generator.generate_key(encrypted_cookie_salt)
    sign_secret = key_generator.generate_key(encrypted_signed_cookie_salt)
    json_value = ActiveSupport::MessageEncryptor.new(secret[0, ActiveSupport::MessageEncryptor.key_len], sign_secret, serializer: JSON).encrypt_and_sign("bar")
    @request.headers["Cookie"] = "foo=#{json_value}"

    get :get_encrypted_cookie

    cookies = @controller.send :cookies
    expect("bar").to_not eq cookies[:foo]
    assert_equal "bar", cookies.encrypted[:foo]

    assert_nil @response.cookies["foo"]
  end

  it "test_compat_encrypted_cookie_using_64_byte_key" do
    # Cookie generated with 64 bytes secret
    message = ["566d4e75536d686e633246564e6b493062557079626c566d51574d30515430394c53315665564a694e4563786555744f57537454576b396a5a31566a626e52525054303d2d2d34663234333330623130623261306163363562316266323335396164666364613564643134623131"].pack("H*")
    @request.headers["Cookie"] = "foo=#{message}"

    get :get_encrypted_cookie

    cookies = @controller.send :cookies
    expect("bar").to_not eq cookies[:foo]
    assert_equal "bar", cookies.encrypted[:foo]
    assert_nil @response.cookies["foo"]
  end

  it "test_accessing_nonexistent_encrypted_cookie_should_not_raise_invalid_message" do
    get :set_encrypted_cookie
    assert_nil @controller.send(:cookies).encrypted[:non_existent_attribute]
  end

  it "test_setting_invalid_encrypted_cookie_should_return_nil_when_accessing_it" do
    get :set_invalid_encrypted_cookie
    assert_nil @controller.send(:cookies).encrypted[:invalid_cookie]
  end

  it "test_permanent_signed_cookie" do
    get :set_permanent_signed_cookie
    assert_match(%r(#{20.years.from_now.utc.year}), @response.headers["Set-Cookie"])
    assert_equal 100, @controller.send(:cookies).signed[:remember_me]
  end

  it "test_delete_and_set_cookie" do
    request.cookies[:user_name] = "Joe"
    get :delete_and_set_cookie
    assert_cookie_header "user_name=david; path=/; expires=Mon, 10 Oct 2005 05:00:00 GMT"
    assert_equal({ "user_name" => "david" }, @response.cookies)
  end

  it "test_raise_data_overflow" do
    assert_raises(ActionDispatch::Cookies::CookieOverflow) do
      get :raise_data_overflow
    end
  end

  it "test_tampered_cookies" do
    assert_nothing_raised do
      get :tampered_cookies
      assert_response :success
    end
  end

  it "test_cookie_jar_mutated_by_request_persists_on_future_requests" do
    get :authenticate
    cookie_jar = @request.cookie_jar
    cookie_jar.signed[:user_id] = 123
    assert_equal ["user_name", "user_id"], @request.cookie_jar.instance_variable_get(:@cookies).keys
    get :get_signed_cookie
    assert_equal ["user_name", "user_id"], @request.cookie_jar.instance_variable_get(:@cookies).keys
  end

  it "test_raises_argument_error_if_missing_secret" do
    assert_raises(ArgumentError, nil.inspect) {
      @request.env["action_dispatch.key_generator"] = ActiveSupport::LegacyKeyGenerator.new(nil)
      get :set_signed_cookie
    }

    assert_raises(ArgumentError, "".inspect) {
      @request.env["action_dispatch.key_generator"] = ActiveSupport::LegacyKeyGenerator.new("")
      get :set_signed_cookie
    }
  end

  it "test_raises_argument_error_if_secret_is_probably_insecure" do
    assert_raises(ArgumentError, "password".inspect) {
      @request.env["action_dispatch.key_generator"] = ActiveSupport::LegacyKeyGenerator.new("password")
      get :set_signed_cookie
    }

    assert_raises(ArgumentError, "secret".inspect) {
      @request.env["action_dispatch.key_generator"] = ActiveSupport::LegacyKeyGenerator.new("secret")
      get :set_signed_cookie
    }

    assert_raises(ArgumentError, "12345678901234567890123456789".inspect) {
      @request.env["action_dispatch.key_generator"] = ActiveSupport::LegacyKeyGenerator.new("12345678901234567890123456789")
      get :set_signed_cookie
    }
  end

  it "test_signed_uses_signed_cookie_jar_if_only_secret_token_is_set" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = nil
    get :set_signed_cookie
    assert_kind_of ActionDispatch::Cookies::SignedCookieJar, cookies.signed
  end

  it "test_signed_uses_signed_cookie_jar_if_only_secret_key_base_is_set" do
    @request.env["action_dispatch.secret_token"] = nil
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    get :set_signed_cookie
    assert_kind_of ActionDispatch::Cookies::SignedCookieJar, cookies.signed
  end

  it "test_signed_uses_upgrade_legacy_signed_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    get :set_signed_cookie
    assert_kind_of ActionDispatch::Cookies::UpgradeLegacySignedCookieJar, cookies.signed
  end

  it "test_signed_or_encrypted_uses_signed_cookie_jar_if_only_secret_token_is_set" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = nil
    get :get_encrypted_cookie
    assert_kind_of ActionDispatch::Cookies::SignedCookieJar, cookies.signed_or_encrypted
  end

  it "test_signed_or_encrypted_uses_encrypted_cookie_jar_if_only_secret_key_base_is_set" do
    @request.env["action_dispatch.secret_token"] = nil
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    get :get_encrypted_cookie
    assert_kind_of ActionDispatch::Cookies::EncryptedCookieJar, cookies.signed_or_encrypted
  end

  it "test_signed_or_encrypted_uses_upgrade_legacy_encrypted_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    get :get_encrypted_cookie
    assert_kind_of ActionDispatch::Cookies::UpgradeLegacyEncryptedCookieJar, cookies.signed_or_encrypted
  end

  it "test_encrypted_uses_encrypted_cookie_jar_if_only_secret_key_base_is_set" do
    @request.env["action_dispatch.secret_token"] = nil
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    get :get_encrypted_cookie
    assert_kind_of ActionDispatch::Cookies::EncryptedCookieJar, cookies.encrypted
  end

  it "test_encrypted_uses_upgrade_legacy_encrypted_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    get :get_encrypted_cookie
    assert_kind_of ActionDispatch::Cookies::UpgradeLegacyEncryptedCookieJar, cookies.encrypted
  end

  it "test_legacy_signed_cookie_is_read_and_transparently_upgraded_by_signed_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33").generate(45)

    @request.headers["Cookie"] = "user_id=#{legacy_value}"
    get :get_signed_cookie

    assert_equal 45, @controller.send(:cookies).signed[:user_id]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.signed_cookie_salt"])
    verifier = ActiveSupport::MessageVerifier.new(secret)
    assert_equal 45, verifier.verify(@response.cookies["user_id"])
  end

  it "test_legacy_signed_cookie_is_read_and_transparently_encrypted_by_encrypted_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    @request.env["action_dispatch.encrypted_cookie_salt"] = "4433796b79d99a7735553e316522acee"
    @request.env["action_dispatch.encrypted_signed_cookie_salt"] = "00646eb40062e1b1deff205a27cd30f9"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33").generate("bar")

    @request.headers["Cookie"] = "foo=#{legacy_value}"
    get :get_encrypted_cookie

    assert_equal "bar", @controller.send(:cookies).encrypted[:foo]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_cookie_salt"])
    sign_secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_signed_cookie_salt"])
    encryptor = ActiveSupport::MessageEncryptor.new(secret[0, ActiveSupport::MessageEncryptor.key_len], sign_secret)
    assert_equal "bar", encryptor.decrypt_and_verify(@response.cookies["foo"])
  end

  it "test_legacy_json_signed_cookie_is_read_and_transparently_upgraded_by_signed_json_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.cookies_serializer"] = :json
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33", serializer: JSON).generate(45)

    @request.headers["Cookie"] = "user_id=#{legacy_value}"
    get :get_signed_cookie

    assert_equal 45, @controller.send(:cookies).signed[:user_id]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.signed_cookie_salt"])
    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON)
    assert_equal 45, verifier.verify(@response.cookies["user_id"])
  end

  it "test_legacy_json_signed_cookie_is_read_and_transparently_encrypted_by_encrypted_json_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.cookies_serializer"] = :json
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    @request.env["action_dispatch.encrypted_cookie_salt"] = "4433796b79d99a7735553e316522acee"
    @request.env["action_dispatch.encrypted_signed_cookie_salt"] = "00646eb40062e1b1deff205a27cd30f9"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33", serializer: JSON).generate("bar")

    @request.headers["Cookie"] = "foo=#{legacy_value}"
    get :get_encrypted_cookie

    assert_equal "bar", @controller.send(:cookies).encrypted[:foo]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_cookie_salt"])
    sign_secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_signed_cookie_salt"])
    encryptor = ActiveSupport::MessageEncryptor.new(secret[0, ActiveSupport::MessageEncryptor.key_len], sign_secret, serializer: JSON)
    assert_equal "bar", encryptor.decrypt_and_verify(@response.cookies["foo"])
  end

  it "test_legacy_json_signed_cookie_is_read_and_transparently_upgraded_by_signed_json_hybrid_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33", serializer: JSON).generate(45)

    @request.headers["Cookie"] = "user_id=#{legacy_value}"
    get :get_signed_cookie

    assert_equal 45, @controller.send(:cookies).signed[:user_id]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.signed_cookie_salt"])
    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON)
    assert_equal 45, verifier.verify(@response.cookies["user_id"])
  end

  it "test_legacy_json_signed_cookie_is_read_and_transparently_encrypted_by_encrypted_hybrid_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    @request.env["action_dispatch.encrypted_cookie_salt"] = "4433796b79d99a7735553e316522acee"
    @request.env["action_dispatch.encrypted_signed_cookie_salt"] = "00646eb40062e1b1deff205a27cd30f9"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33", serializer: JSON).generate("bar")

    @request.headers["Cookie"] = "foo=#{legacy_value}"
    get :get_encrypted_cookie

    assert_equal "bar", @controller.send(:cookies).encrypted[:foo]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_cookie_salt"])
    sign_secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_signed_cookie_salt"])
    encryptor = ActiveSupport::MessageEncryptor.new(secret[0, ActiveSupport::MessageEncryptor.key_len], sign_secret, serializer: JSON)
    assert_equal "bar", encryptor.decrypt_and_verify(@response.cookies["foo"])
  end

  it "test_legacy_marshal_signed_cookie_is_read_and_transparently_upgraded_by_signed_json_hybrid_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33").generate(45)

    @request.headers["Cookie"] = "user_id=#{legacy_value}"
    get :get_signed_cookie

    assert_equal 45, @controller.send(:cookies).signed[:user_id]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.signed_cookie_salt"])
    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON)
    assert_equal 45, verifier.verify(@response.cookies["user_id"])
  end

  it "test_legacy_marshal_signed_cookie_is_read_and_transparently_encrypted_by_encrypted_hybrid_cookie_jar_if_both_secret_token_and_secret_key_base_are_set" do
    @request.env["action_dispatch.cookies_serializer"] = :hybrid
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"
    @request.env["action_dispatch.encrypted_cookie_salt"] = "4433796b79d99a7735553e316522acee"
    @request.env["action_dispatch.encrypted_signed_cookie_salt"] = "00646eb40062e1b1deff205a27cd30f9"

    legacy_value = ActiveSupport::MessageVerifier.new("b3c631c314c0bbca50c1b2843150fe33").generate("bar")

    @request.headers["Cookie"] = "foo=#{legacy_value}"
    get :get_encrypted_cookie

    assert_equal "bar", @controller.send(:cookies).encrypted[:foo]

    key_generator = @request.env["action_dispatch.key_generator"]
    secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_cookie_salt"])
    sign_secret = key_generator.generate_key(@request.env["action_dispatch.encrypted_signed_cookie_salt"])
    encryptor = ActiveSupport::MessageEncryptor.new(secret[0, ActiveSupport::MessageEncryptor.key_len], sign_secret, serializer: JSON)
    assert_equal "bar", encryptor.decrypt_and_verify(@response.cookies["foo"])
  end

  it "test_legacy_signed_cookie_is_treated_as_nil_by_signed_cookie_jar_if_tampered" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"

    @request.headers["Cookie"] = "user_id=45"
    get :get_signed_cookie

    assert_nil @controller.send(:cookies).signed[:user_id]
    assert_nil @response.cookies["user_id"]
  end

  it "test_legacy_signed_cookie_is_treated_as_nil_by_encrypted_cookie_jar_if_tampered" do
    @request.env["action_dispatch.secret_token"] = "b3c631c314c0bbca50c1b2843150fe33"
    @request.env["action_dispatch.secret_key_base"] = "c3b95688f35581fad38df788add315ff"

    @request.headers["Cookie"] = "foo=baz"
    get :get_encrypted_cookie

    assert_nil @controller.send(:cookies).encrypted[:foo]
    assert_nil @response.cookies["foo"]
  end

  it "test_cookie_with_all_domain_option" do
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.com; path=/"
  end

  it "test_cookie_with_all_domain_option_using_a_non_standard_tld" do
    @request.host = "two.subdomains.nextangle.local"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.local; path=/"
  end

  it "test_cookie_with_all_domain_option_using_australian_style_tld" do
    @request.host = "nextangle.com.au"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.com.au; path=/"
  end

  it "test_cookie_with_all_domain_option_using_australian_style_tld_and_two_subdomains" do
    @request.host = "x.nextangle.com.au"
    get :set_cookie_with_domain
    assert_response :success
   assert_cookie_header "user_name=rizwanreza; domain=.nextangle.com.au; path=/"
  end

  it "test_cookie_with_all_domain_option_using_uk_style_tld" do
    @request.host = "nextangle.co.uk"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.co.uk; path=/"
  end

  it "test_cookie_with_all_domain_option_using_uk_style_tld_and_two_subdomains" do
    @request.host = "x.nextangle.co.uk"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.co.uk; path=/"
  end

  it "test_cookie_with_all_domain_option_using_host_with_port" do
    @request.host = "nextangle.local:3000"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.local; path=/"
  end

  it "test_cookie_with_all_domain_option_using_localhost" do
    @request.host = "localhost"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; path=/"
  end

  it "test_cookie_with_all_domain_option_using_ipv4_address" do
    @request.host = "192.168.1.1"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; path=/"
  end

  it "test_cookie_with_all_domain_option_using_ipv6_address" do
    @request.host = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    get :set_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; path=/"
  end

  it "test_deleting_cookie_with_all_domain_option" do
    request.cookies[:user_name] = "Joe"
    get :delete_cookie_with_domain
    assert_response :success
    assert_cookie_header "user_name=; domain=.nextangle.com; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
  end

  it "test_cookie_with_all_domain_option_and_tld_length" do
    get :set_cookie_with_domain_and_tld
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.com; path=/"
  end

  it "test_cookie_with_all_domain_option_using_a_non_standard_tld_and_tld_length" do
    @request.host = "two.subdomains.nextangle.local"
    get :set_cookie_with_domain_and_tld
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.local; path=/"
  end

  it "test_cookie_with_all_domain_option_using_a_non_standard_2_letter_tld" do
    @request.host = "admin.lvh.me"
    get :set_cookie_with_domain_and_tld
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.lvh.me; path=/"
  end

  it "test_cookie_with_all_domain_option_using_host_with_port_and_tld_length" do
    @request.host = "nextangle.local:3000"
    get :set_cookie_with_domain_and_tld
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.nextangle.local; path=/"
  end

  it "test_cookie_with_all_domain_option_using_longer_tld_length" do
    @request.host = "x.y.z.t.com"
    get :set_cookie_with_domain_and_longer_tld
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.y.z.t.com; path=/"
  end

  it "test_deleting_cookie_with_all_domain_option_and_tld_length" do
    request.cookies[:user_name] = "Joe"
    get :delete_cookie_with_domain_and_tld
    assert_response :success
    assert_cookie_header "user_name=; domain=.nextangle.com; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
  end

  it "test_cookie_with_several_preset_domains_using_one_of_these_domains" do
    @request.host = "example1.com"
    get :set_cookie_with_domains
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=example1.com; path=/"
  end

  it "test_cookie_with_several_preset_domains_using_other_domain" do
    @request.host = "other-domain.com"
    get :set_cookie_with_domains
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; path=/"
  end

  it "test_cookie_with_several_preset_domains_using_shared_domain" do
    @request.host = "example3.com"
    get :set_cookie_with_domains
    assert_response :success
    assert_cookie_header "user_name=rizwanreza; domain=.example3.com; path=/"
  end

  it "test_deletings_cookie_with_several_preset_domains_using_one_of_these_domains" do
    @request.host = "example2.com"
    request.cookies[:user_name] = "Joe"
    get :delete_cookie_with_domains
    assert_response :success
    assert_cookie_header "user_name=; domain=example2.com; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
  end

  it "test_deletings_cookie_with_several_preset_domains_using_other_domain" do
    @request.host = "other-domain.com"
    request.cookies[:user_name] = "Joe"
    get :delete_cookie_with_domains
    assert_response :success
    assert_cookie_header "user_name=; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
  end

  it "test_cookies_hash_is_indifferent_access" do
    get :symbol_key
    assert_equal "david", cookies[:user_name]
    assert_equal "david", cookies["user_name"]
    get :string_key
    assert_equal "dhh", cookies[:user_name]
    assert_equal "dhh", cookies["user_name"]
  end

  it "test_setting_request_cookies_is_indifferent_access" do
    cookies.clear
    cookies[:user_name] = "andrew"
    get :string_key_mock
    assert_equal "david", cookies["user_name"]

    cookies.clear
    cookies["user_name"] = "andrew"
    get :symbol_key_mock
    assert_equal "david", cookies[:user_name]
  end

  it "test_cookies_retained_across_requests" do
    get :symbol_key
    assert_cookie_header "user_name=david; path=/"
    assert_equal "david", cookies[:user_name]

    get :noop
    assert_nil @response.headers["Set-Cookie"]
    assert_equal "david", cookies[:user_name]

    get :noop
    assert_nil @response.headers["Set-Cookie"]
    assert_equal "david", cookies[:user_name]
  end

  it "test_cookies_can_be_cleared" do
    get :symbol_key
    assert_equal "david", cookies[:user_name]

    cookies.clear
    get :noop
    assert_nil cookies[:user_name]

    get :symbol_key
    assert_equal "david", cookies[:user_name]
  end

  it "test_can_set_http_cookie_header" do
    @request.env["HTTP_COOKIE"] = "user_name=david"
    get :noop
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]

    get :noop
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]

    @request.env["HTTP_COOKIE"] = "user_name=andrew"
    get :noop
    assert_equal "andrew", cookies["user_name"]
    assert_equal "andrew", cookies[:user_name]
  end

  it "test_can_set_request_cookies" do
    @request.cookies["user_name"] = "david"
    get :noop
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]

    get :noop
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]

    @request.cookies[:user_name] = "andrew"
    get :noop
    assert_equal "andrew", cookies["user_name"]
    assert_equal "andrew", cookies[:user_name]
  end

  it "test_cookies_precedence_over_http_cookie" do
    @request.env["HTTP_COOKIE"] = "user_name=andrew"
    get :authenticate
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]

    get :noop
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]
  end

  it "test_cookies_precedence_over_request_cookies" do
    @request.cookies["user_name"] = "andrew"
    get :authenticate
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]

    get :noop
    assert_equal "david", cookies["user_name"]
    assert_equal "david", cookies[:user_name]
  end

  it "test_cookies_are_not_cleared" do
    cookies.encrypted["foo"] = "bar"
    get :noop
    assert_equal "bar", @controller.encrypted_cookie
  end

  private
    def assert_cookie_header(expected)
      header = @response.headers["Set-Cookie"]
      if header.respond_to?(:to_str)
        assert_equal expected.split("\n").sort, header.split("\n").sort
      else
        assert_equal expected.split("\n"), header
      end
    end

    def assert_not_cookie_header(expected)
      header = @response.headers["Set-Cookie"]
      if header.respond_to?(:to_str)
        expect(expected.split("\n").sort).to_not eq header.split("\n").sort
      else
        expect(expected.split("\n")).to_not eq header
      end
    end
end
