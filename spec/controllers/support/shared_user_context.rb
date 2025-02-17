# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

RSpec.shared_context :shared_user_context do
  let(:nonprofit) { force_create(:nm_justice, published: true) }
  let(:other_nonprofit) { force_create(:fv_poverty) }

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

  let(:campaign) { force_create(:campaign, nonprofit: nonprofit) }
  let(:campaign_editor) do
    __create(:campaign_editor, campaign)
  end

  let(:confirmed_user) do
    force_create(:user, confirmed_at: Time.current)
  end

  let(:event) do
    force_create(:event, nonprofit: nonprofit)
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

  def send(method, action, args = {})
    case method
    when :get
      get(action, **args)
    when :post
      post(action, **args)
    when :delete
      delete(action, **args)
    when :put
      put(action, **args)
    end
  end

  def accept(user_to_signin, method, action, *args)
    test_variables = collect_test_variables(args)
    request.accept = "application/json" unless test_variables[:without_json_view]
    sign_in user_to_signin if user_to_signin
    # allows us to run the helpers but ignore what the controller action does

    if test_variables[:without_json_view]
      expect_any_instance_of(described_class).to receive(action).and_return(ActionDispatch::IntegrationTest.new(200))
      expect_any_instance_of(described_class).to receive(:render).and_return(nil)
      send(method, action, reduce_params(*args))
      expect(response.status).to eq 200
    else
      expect_any_instance_of(described_class).to receive(action).and_return(ActionDispatch::IntegrationTest.new(204))
      send(method, action, reduce_params(*args))
      expect(response.status).to eq(test_variables[:with_status] || 204)
    end
  end

  def reject(user_to_signin, method, action, *args)
    sign_in user_to_signin if user_to_signin
    send(method, action, reduce_params(*args))
    expect(response.status).to eq 302
  end

  alias_method :redirects_to, :reject

  def reduce_params(*args)
    {params: args.reduce({}, :merge)}
  end

  def collect_test_variables(*args)
    test_vars = {}
    args.collect do |items|
      if items.is_a?(Array)
        items.each do |k, v|
          test_vars.merge!(k.slice(:without_json_view, :with_status)) if k.is_a?(Hash)
        end
      end
    end
    test_vars
  end

  def fix_args(*args)
    replacements = {
      __our_np: nonprofit.id,
      __our_campaign: campaign.id,
      __our_event: event.id,
      __our_profile: user_with_profile.profile.id
    }

    args.collect do |i|
      ret = i

      if replacements[i]
        ret = replacements[i]

      elsif i.is_a? Hash
        ret = i.collect do |k, v|
          ret_v = v
          ret_v = replacements[v] if replacements[v]

          [k, ret_v]
        end.to_h
      end

      ret
    end.to_a
  end
end

RSpec.shared_context :open_to_all do |method, action, *args|
  include_context :shared_user_context

  let(:fixed_args) do
    fix_args(*args)
  end
  it "accepts no user" do
    accept(nil, method, action, *fixed_args)
  end

  it "accepts user with no roles" do
    accept(unauth_user, method, action, *fixed_args)
  end

  it "accepts nonprofit admin" do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it "accepts nonprofit associate" do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it "accepts other admin" do
    accept(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "accepts other associate" do
    accept(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "accepts campaign editor" do
    accept(campaign_editor, method, action, *fixed_args)
  end

  it "accept confirmed user" do
    accept(confirmed_user, method, action, *fixed_args)
  end

  it "accept event editor" do
    accept(event_editor, method, action, *fixed_args)
  end

  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "accept profile user" do
    accept(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_np_associate do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "rejects user with no roles" do
    reject(unauth_user, method, action, *fixed_args)
  end

  it "accepts nonprofit admin" do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it "accepts nonprofit associate" do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it "rejects other admin" do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "rejects other associate" do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "rejects campaign editor" do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it "rejects confirmed user" do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it "reject event editor" do
    reject(event_editor, method, action, *fixed_args)
  end

  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "rejects profile user" do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_np_admin do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "rejects user with no roles" do
    reject(unauth_user, method, action, *fixed_args)
  end

  it "accepts nonprofit admin" do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it "rejects nonprofit associate" do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it "rejects other admin" do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "rejects other associate" do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "rejects campaign editor" do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it "rejects confirmed user" do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it "reject event editor" do
    reject(event_editor, method, action, *fixed_args)
  end
  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "rejects profile user" do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_registered do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "accepts user with no roles" do
    accept(unauth_user, method, action, *fixed_args)
  end

  it "accepts nonprofit admin" do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it "accepts nonprofit associate" do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it "accepts other admin" do
    accept(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "accepts other associate" do
    accept(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "accepts campaign editor" do
    accept(campaign_editor, method, action, *fixed_args)
  end

  it "accepts confirmed user" do
    accept(confirmed_user, method, action, *fixed_args)
  end

  it "accept event editor" do
    accept(event_editor, method, action, *fixed_args)
  end
  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "accept profile user" do
    accept(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_campaign_editor do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "rejects user with no roles" do
    reject(unauth_user, method, action, *fixed_args)
  end

  it "accepts nonprofit admin" do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it "accepts nonprofit associate" do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it "rejects other admin" do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "rejects other associate" do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "accepts campaign editor" do
    accept(campaign_editor, method, action, *fixed_args)
  end

  it "rejects confirmed user" do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it "reject event editor" do
    reject(event_editor, method, action, *fixed_args)
  end
  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "rejects profile user" do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_confirmed_users do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "rejects user with no roles" do
    reject(unauth_user, method, action, *fixed_args)
  end

  it "reject nonprofit admin" do
    reject(user_as_np_admin, method, action, *fixed_args)
  end

  it "reject nonprofit associate" do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it "rejects other admin" do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "rejects other associate" do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "reject campaign editor" do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it "accepts confirmed user" do
    accept(confirmed_user, method, action, *fixed_args)
  end

  it "reject event editor" do
    reject(event_editor, method, action, *fixed_args)
  end
  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "rejects profile user" do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_event_editor do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "rejects user with no roles" do
    reject(unauth_user, method, action, *fixed_args)
  end

  it "accept nonprofit admin" do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it "nonprofit associate" do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it "rejects other admin" do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "rejects other associate" do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "reject campaign editor" do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it "reject confirmed user" do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it "accept event editor" do
    accept(event_editor, method, action, *fixed_args)
  end
  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end
  it "rejects profile user" do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_super_admin do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "rejects user with no roles" do
    reject(unauth_user, method, action, *fixed_args)
  end

  it "rejects nonprofit admin" do
    reject(user_as_np_admin, method, action, *fixed_args)
  end

  it "rejects nonprofit associate" do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it "rejects other admin" do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "rejects other associate" do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "rejects campaign editor" do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it "rejects confirmed user" do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it "reject event editor" do
    reject(event_editor, method, action, *fixed_args)
  end

  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "rejects profile user" do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_profile_owner do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args) do
    fix_args(*args)
  end

  it "rejects no user" do
    reject(nil, method, action, *fixed_args)
  end

  it "rejects user with no roles" do
    reject(unauth_user, method, action, *fixed_args)
  end

  it "rejects nonprofit admin" do
    reject(user_as_np_admin, method, action, *fixed_args)
  end

  it "rejects nonprofit associate" do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it "rejects other admin" do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it "rejects other associate" do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it "rejects campaign editor" do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it "rejects confirmed user" do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it "reject event editor" do
    reject(event_editor, method, action, *fixed_args)
  end

  it "accepts super admin" do
    accept(super_admin, method, action, *fixed_args)
  end

  it "accepts profile user" do
    accept(user_with_profile, method, action, *fixed_args)
  end
end
