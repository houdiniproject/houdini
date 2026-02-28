# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "support/contexts/general_shared_user_context"

RSpec.shared_context :new_controller_user_context do
  include_context :general_shared_user_context

  def sign_in(user_to_signin)
    post_via_redirect "users/sign_in", "user[email]" => user_to_signin.email, "user[password]" => user_to_signin.password, :format => "json"
  end

  def sign_out
    send(:get, "users/sign_out")
  end

  def send(method, *args)
    case method
    when :get
      xhr(:get, *args)
    when :post
      xhr(:post, *args)
    when :delete
      xhr(:delete, *args)
    when :put
      xhr(:put, *args)
    end
  end

  def accept(user_to_signin:, method:, action:, args:)
    new_user = user_to_signin
    if !user_to_signin.nil? && user_to_signin.is_a?(OpenStruct)
      new_user = user_to_signin.value
    end
    sign_in new_user if new_user
    # allows us to run the helpers but ignore what the controller action does
    # expect_any_instance_of(described_class).to receive(action).and_return(ActionController::TestResponse.new(200))
    # expect_any_instance_of(described_class).to receive(:render).and_return(nil)
    send(method, action, args)
    expect(response.status).to_not eq(302), "expected success for user: #{user_to_signin.is_a?(OpenStruct) ? user_to_signin.key.to_s + ":" : ""} #{new_user&.attributes}"
    sign_out
  end

  def reject(user_to_signin:, method:, action:, args:)
    new_user = user_to_signin
    if !user_to_signin.nil? && user_to_signin.is_a?(OpenStruct)
      new_user = user_to_signin.value
    end
    sign_in new_user if new_user
    send(method, action, args)
    expect(response.status).to eq(302), "expected failure for user: #{user_to_signin.is_a?(OpenStruct) ? user_to_signin.key.to_s + ":" : ""} #{new_user&.attributes}"
    sign_out
  end
end
