# based on actionpack/test/dispatch/request_test.rb in rails

require 'rails_helper'

describe 'tests for making sure CVE-2023-22795 patch doesnt break anything' do

  before(:each) do
    @env = {
      :ip_spoofing_check => true,
      :tld_length => 1,
      "rack.input" => "foo"
    }
  end

  def url_for(options = {})
    options = { host: 'www.example.com' }.merge!(options)
    ActionDispatch::Http::URL.url_for(options)
  end

  
  def stub_request(env = {})
    ip_spoofing_check = env.key?(:ip_spoofing_check) ? env.delete(:ip_spoofing_check) : true
    @trusted_proxies ||= nil
    ip_app = ActionDispatch::RemoteIp.new(Proc.new { }, ip_spoofing_check, @trusted_proxies)
    tld_length = env.key?(:tld_length) ? env.delete(:tld_length) : 1
    ip_app.call(env)
    ActionDispatch::Http::URL.tld_length = tld_length

    env = @env.merge(env)
    ActionDispatch::Request.new(env)
  end

  describe 'request etag' do
    it "if_none_match_etags none" do
      request = stub_request
  
      assert_equal nil, request.if_none_match
      assert_equal [], request.if_none_match_etags
      assert !request.etag_matches?("foo")
      assert !request.etag_matches?(nil)
    end
  
    it "if_none_match_etags single" do
      header = 'the-etag'
      request = stub_request('HTTP_IF_NONE_MATCH' => header)
  
      assert_equal header, request.if_none_match
      assert_equal [header], request.if_none_match_etags
      assert request.etag_matches?("the-etag")
    end
  
    it "if_none_match_etags quoted single" do
      header = '"the-etag"'
      request = stub_request('HTTP_IF_NONE_MATCH' => header)
  
      assert_equal header, request.if_none_match
      assert_equal ['the-etag'], request.if_none_match_etags
      assert request.etag_matches?("the-etag")
    end
  
    it "if_none_match_etags multiple" do
      header = 'etag1, etag2, "third etag", "etag4"'
      expected = ['etag1', 'etag2', 'third etag', 'etag4']
      request = stub_request('HTTP_IF_NONE_MATCH' => header)
  
      assert_equal header, request.if_none_match
      assert_equal expected, request.if_none_match_etags
      expected.each do |etag|
        assert request.etag_matches?(etag), etag
      end
    end
  end
end