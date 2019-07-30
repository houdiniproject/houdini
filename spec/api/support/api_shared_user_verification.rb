# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'controllers/support/general_shared_user_context'
RSpec.shared_context :api_shared_user_verification do
  include_context :general_shared_user_context
  let(:user_as_np_admin) do
    __create_admin(nonprofit)
  end

  let(:user_as_other_np_admin) do
    __create_admin(other_nonprofit)
  end

  let(:user_as_np_associate) do
    __create_associate(nonprofit)
  end

  let(:user_as_other_np_associate) do
    __create_associate(other_nonprofit)
  end

  let(:unauth_user) do
    force_create(:user)
  end

  let(:campaign_editor) do
    __create(:campaign_editor, campaign)
  end

  let(:confirmed_user)  do
    force_create(:user, confirmed_at: Time.current)
  end

  let(:event_editor) do
    __create(:event_editor, event)
  end

  let(:super_admin) do
    __create(:super_admin, other_nonprofit)
  end

  let(:user_with_profile) do
    u = force_create(:user)
    force_create(:profile, user: u)
    u
  end

  let(:all_users) do
    { user_as_np_admin: user_as_np_admin,
      user_as_other_np_admin: user_as_other_np_admin,
      user_as_np_associate: user_as_np_associate,
      user_as_other_np_associate: user_as_other_np_associate,
      unauth_user: unauth_user,
      campaign_editor: campaign_editor,
      event_editor: event_editor,
      super_admin: super_admin,
      user_with_profile: user_with_profile }
  end

  let(:roles__open_to_all) do
    [nil, :user_as_np_admin,
     :user_as_other_np_admin,
     :user_as_np_associate,
     :user_as_other_np_associate,
     :unauth_user,
     :campaign_editor,
     :event_editor,
     :super_admin,
     :user_with_profile]
  end

  let(:roles__open_to_np_associate) do
    %i[user_as_np_admin

       user_as_np_associate

       super_admin]
  end

  def __create(name, host)
    u = force_create(:user)
    force_create(:role, user: u, name: name, host: host)
    u
  end

  def __create_admin(host)
    u = force_create(:user)
    force_create(:role, user: u, name: :nonprofit_admin, host: host)
    u
  end

  def __create_associate(host)
    u = force_create(:user)
    force_create(:role, user: u, name: :nonprofit_associate, host: host)
    u
  end

  def sign_in(user_to_signin)
    post_via_redirect 'users/sign_in', 'user[email]' => user_to_signin.email, 'user[password]' => user_to_signin.password, format: 'json'
  end

  def sign_out
    send(:get, 'users/sign_out')
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
    #
    send(method, action, args)
    expect(response.status).to eq(200), "expcted success for user: #{(user_to_signin.is_a?(OpenStruct) ? user_to_signin.key.to_s + ':' : '')} #{new_user&.attributes}"
    sign_out
  end

  def reject(user_to_signin:, method:, action:, args:)
    new_user = user_to_signin
    if !user_to_signin.nil? && user_to_signin.is_a?(OpenStruct)
      new_user = user_to_signin.value
    end
    sign_in new_user if new_user
    send(method, action, args)
    expect(response.status).to eq(401), "expected failure for user: #{(user_to_signin.is_a?(OpenStruct) ? user_to_signin.key.to_s + ':' : '')} #{new_user&.attributes}"
    sign_out
  end

  alias_method :redirects_to, :reject

  def run_authorization_tests(details, &block)
    @method = details[:method]
    @successful_users = details[:successful_users]
    @action = details[:action]
    @block_to_get_arguments_to_run = block || ->(_) {} # no-op
    accept_test_for_nil = false
    all_users.each do |k, v|
      os = OpenStruct.new
      os.key = k
      os.value = v

      if k.nil?
        accept(user_to_signin: nil, method: @method, action: @action, args: @block_to_get_arguments_to_run.call(v))
        accept_test_for_nil = true
      end
      if @successful_users.include? k
        accept(user_to_signin: os, method: @method, action: @action, args: @block_to_get_arguments_to_run.call(v))
      else
        reject(user_to_signin: os, method: @method, action: @action, args: @block_to_get_arguments_to_run.call(v))
      end
    end

    unless accept_test_for_nil
      reject(user_to_signin: nil, method: @method, action: @action, args: @block_to_get_arguments_to_run.call(nil))
    end
  end
end
