# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
RSpec.shared_context :general_shared_user_context do
  let(:user_as_np_admin) {
    __create_admin(nonprofit)
  }

  let(:user_as_other_np_admin) {
    __create_admin(other_nonprofit)
  }

  let(:user_as_np_associate) {
    __create_associate(nonprofit)
  }

  let(:user_as_other_np_associate) {
    __create_associate(other_nonprofit)
  }

  let(:unauth_user) {
    force_create(:user)
  }

  let(:campaign_editor) {
    __create(:campaign_editor, campaign)
  }

  let(:confirmed_user) {
    force_create(:user, confirmed_at: Time.current)
  }

  let(:event_editor) {
    __create(:event_editor, event)
  }

  let(:super_admin) {
    __create(:super_admin, other_nonprofit)
  }

  let(:user_with_profile) {
    u = force_create(:user)
    force_create(:profile, user: u)
    u
  }

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
    [:user_as_np_admin,

      :user_as_np_associate,

      :super_admin]
  end

  let(:roles__open_to_campaign_editor) do
    [:user_as_np_admin,
      :user_as_np_associate,
      :campaign_editor,
      :super_admin]
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
