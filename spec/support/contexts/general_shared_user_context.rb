# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
RSpec.shared_context :general_shared_user_context do
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

  let(:confirmed_user) do
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
    {user_as_np_admin: user_as_np_admin,
     user_as_other_np_admin: user_as_other_np_admin,
     user_as_np_associate: user_as_np_associate,
     user_as_other_np_associate: user_as_other_np_associate,
     unauth_user: unauth_user,
     campaign_editor: campaign_editor,
     event_editor: event_editor,
     super_admin: super_admin,
     user_with_profile: user_with_profile}
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

  let(:roles__open_to_campaign_editor) do
    %i[user_as_np_admin
      user_as_np_associate
      campaign_editor
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
