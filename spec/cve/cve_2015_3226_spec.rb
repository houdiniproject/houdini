# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

describe ActiveSupport::JSON::Encoding do
  it 'test_hash_keys_encoding' do
    # from https://groups.google.com/forum/message/raw?msg=rubyonrails-security/7VlB_pck3hU/3QZrGIaQW6cJ

    ActiveSupport.escape_html_entities_in_json = true
    expect(ActiveSupport::JSON.encode('<>' => '<>').downcase).to eq '{"\\u003c\\u003e":"\\u003c\\u003e"}'
  ensure
    ActiveSupport.escape_html_entities_in_json = false
  end
end
