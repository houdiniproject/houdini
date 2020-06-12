# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'
require 'rack/ssl'
describe Rack::SSL do
  describe '.call' do
    it 'invalid uri returns 404' do
      def test_invalid_uri_returns_404
        # Can't test this with Rack::Test because it fails on the URI before it
        # even gets to Rack::SSL. Other webservers will pass this URI through.
        ssl  = Rack::SSL.new(nil)
        resp = ssl.call('PATH_INFO' => 'https://example.org/path/<script>')
        expect(resp[0]).to eq 404
      end
    end
  end
end
