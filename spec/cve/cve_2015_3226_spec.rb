require 'rails_helper'

describe ActiveSupport::JSON::Encoding do
  it 'test_hash_keys_encoding' do
    #from https://groups.google.com/forum/message/raw?msg=rubyonrails-security/7VlB_pck3hU/3QZrGIaQW6cJ
    begin
      ActiveSupport.escape_html_entities_in_json = true
      expect(ActiveSupport::JSON.encode("<>" => "<>").downcase).to eq "{\"\\u003c\\u003e\":\"\\u003c\\u003e\"}"
    ensure
      ActiveSupport.escape_html_entities_in_json = false
    end
  end
end
