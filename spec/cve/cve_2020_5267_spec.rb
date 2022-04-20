# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# from rails -- actionview/test/template/javascript_helper_test.rb
require 'rails_helper'

describe 'CVE Test 2020-5297' do
  include ActionView::Helpers::JavaScriptHelper 
  it 'test_escape_backtick' do
    assert_equal "\\`", escape_javascript("`")
  end

  it "test_escape_dollar_sign" do
    assert_equal "\\$", escape_javascript("$")
  end
end