# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

describe Rack::Utils do
  describe '.parse_nested_query' do
    it 'raise an exception if the params are too deep' do
      len = Rack::Utils.param_depth_limit

      expect { Rack::Utils.parse_nested_query("foo#{'[a]' * len}=bar") }.to raise_error(RangeError)

      expect { Rack::Utils.parse_nested_query("foo#{'[a]' * (len - 1)}=bar") }.to_not raise_error
    end
  end
end
