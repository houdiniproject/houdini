# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later


RSpec.shared_context :shared_user_context do


  let(:nonprofit) {force_create(:nonprofit, published:true)}
  let(:other_nonprofit) { force_create(:nonprofit)}


  let(:user_as_np_admin) {
    __create_admin(nonprofit)
  }


  let(:user_as_other_np_admin) {
    __create_admin(other_nonprofit)
  }

  let(:user_as_np_associate){
    __create_associate(nonprofit)
  }

  let(:user_as_other_np_associate){
    __create_associate(other_nonprofit)
  }

  let(:unauth_user) {
    force_create(:user)
  }

  let(:campaign) {force_create(:campaign, nonprofit: nonprofit)}
  let(:campaign_editor) {
    __create(:campaign_editor, campaign)
  }

  let(:confirmed_user){
    force_create(:user, confirmed_at: Time.current)
  }

  let(:event) {
    force_create(:event, nonprofit: nonprofit)
  }

  let(:event_editor) {
    __create(:event_editor,event)
  }

  let(:super_admin) {
      __create(:super_admin, other_nonprofit)
  }

  let(:user_with_profile) {
    u = force_create(:user)
    force_create(:profile, user: u)
    u
  }



  def __create(name, host)
    u = force_create(:user)
    force_create(:role, user: u, name: name, host:host)
    u
  end

  def __create_admin(host)
    u = force_create(:user)
    force_create(:role, user: u, name: :nonprofit_admin, host:host)
    u
  end

  def __create_associate(host)
    u = force_create(:user)
    force_create(:role, user: u, name: :nonprofit_associate, host:host)
    u
  end

  def send(method, *args)
    case method
      when :get
        return get(*args)
      when :post
        return post(*args)
      when :delete
        return delete(*args)
      when :put
        return put(*args)
    end
  end

  def accept(user_to_signin, method, action, *args)
    sign_in user_to_signin if user_to_signin
    # allows us to run the helpers but ignore what the controller action does
    #
    expect_any_instance_of(described_class).to receive(action).and_return(ActionController::TestResponse.new(200))
    expect_any_instance_of(described_class).to receive(:render).and_return(nil)
    send(method, action, *args)
    expect(response.status).to eq 200
  end

  def reject(user_to_signin, method, action, *args)
    sign_in user_to_signin if user_to_signin
    send(method, action, *args)
    expect(response.status).to eq 302
  end

  alias_method :redirects_to, :reject

  def fix_args( *args)
    replacements = {
        __our_np: nonprofit.id,
        __our_campaign: campaign.id,
        __our_event: event.id,
        __our_profile: user_with_profile.profile.id
    }

    args.collect{|i|
      ret = i

      if replacements[i]
        ret = replacements[i]

      elsif i.is_a? Hash
        ret = i.collect{|k,v |
          ret_v = v
          if replacements[v]
            ret_v = replacements[v]
          end

          [k,ret_v]
        }.to_h
      end

      ret
    }.to_a
  end


end

RSpec.shared_context :open_to_all do |method, action, *args|
  include_context :shared_user_context

  let(:fixed_args){
    fix_args( *args)
  }
  it 'accepts no user' do
    accept(nil, method, action, *fixed_args)
  end

  it 'accepts user with no roles' do
    accept(unauth_user, method, action, *fixed_args)
  end

  it 'accepts nonprofit admin' do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it 'accepts nonprofit associate' do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it 'accepts other admin' do
    accept(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'accepts other associate' do
    accept(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'accepts campaign editor' do
    accept(campaign_editor, method, action, *fixed_args)
  end

  it 'accept confirmed user' do
    accept(confirmed_user, method, action, *fixed_args)
  end

  it 'accept event editor' do
    accept(event_editor, method, action, *fixed_args)
  end

  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'accept profile user' do
    accept(user_with_profile, method, action, *fixed_args)
  end

end

RSpec.shared_context :open_to_np_associate do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'rejects user with no roles' do
    reject(unauth_user, method, action, *fixed_args)
  end

  it 'accepts nonprofit admin' do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it 'accepts nonprofit associate' do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it 'rejects other admin' do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'rejects other associate' do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'rejects campaign editor' do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it 'rejects confirmed user' do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it 'reject event editor' do
    reject(event_editor, method, action, *fixed_args)
  end

  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'rejects profile user' do
    reject(user_with_profile, method, action, *fixed_args)
  end
end


RSpec.shared_context :open_to_np_admin do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'rejects user with no roles' do
    reject(unauth_user, method, action, *fixed_args)
  end

  it 'accepts nonprofit admin' do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it 'rejects nonprofit associate' do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it 'rejects other admin' do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'rejects other associate' do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'rejects campaign editor' do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it 'rejects confirmed user' do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it 'reject event editor' do
    reject(event_editor, method, action, *fixed_args)
  end
  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'rejects profile user' do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_registered do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'accepts user with no roles' do
    accept(unauth_user, method, action, *fixed_args)
  end

  it 'accepts nonprofit admin' do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it 'accepts nonprofit associate' do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it 'accepts other admin' do
    accept(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'accepts other associate' do
    accept(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'accepts campaign editor' do
    accept(campaign_editor, method, action, *fixed_args)
  end

  it 'accepts confirmed user' do
    accept(confirmed_user, method, action, *fixed_args)
  end

  it 'accept event editor' do
    accept(event_editor, method, action, *fixed_args)
  end
  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'accept profile user' do
    accept(user_with_profile, method, action, *fixed_args)
  end
end


RSpec.shared_context :open_to_campaign_editor do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'rejects user with no roles' do
    reject(unauth_user, method, action, *fixed_args)
  end

  it 'accepts nonprofit admin' do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it 'accepts nonprofit associate' do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it 'rejects other admin' do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'rejects other associate' do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'accepts campaign editor' do
    accept(campaign_editor, method, action, *fixed_args)
  end

  it 'rejects confirmed user' do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it 'reject event editor' do
    reject(event_editor, method, action, *fixed_args)
  end
  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'rejects profile user' do
    reject(user_with_profile, method, action, *fixed_args)
  end

end

RSpec.shared_context :open_to_confirmed_users do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'rejects user with no roles' do
    reject(unauth_user, method, action, *fixed_args)
  end

  it 'reject nonprofit admin' do
    reject(user_as_np_admin, method, action, *fixed_args)
  end

  it 'reject nonprofit associate' do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it 'rejects other admin' do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'rejects other associate' do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'reject campaign editor' do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it 'accepts confirmed user' do
    accept(confirmed_user, method, action, *fixed_args)
  end

  it 'reject event editor' do
    reject(event_editor, method, action, *fixed_args)
  end
  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'rejects profile user' do
    reject(user_with_profile, method, action, *fixed_args)
  end

end

RSpec.shared_context :open_to_event_editor do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'rejects user with no roles' do
    reject(unauth_user, method, action, *fixed_args)
  end

  it 'accept nonprofit admin' do
    accept(user_as_np_admin, method, action, *fixed_args)
  end

  it 'nonprofit associate' do
    accept(user_as_np_associate, method, action, *fixed_args)
  end

  it 'rejects other admin' do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'rejects other associate' do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'reject campaign editor' do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it 'reject confirmed user' do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it 'accept event editor' do
    accept(event_editor, method, action, *fixed_args)
  end
  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end
  it 'rejects profile user' do
    reject(user_with_profile, method, action, *fixed_args)
  end
end

RSpec.shared_context :open_to_super_admin do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'rejects user with no roles' do
    reject(unauth_user, method, action, *fixed_args)
  end

  it 'rejects nonprofit admin' do
    reject(user_as_np_admin, method, action, *fixed_args)
  end

  it 'rejects nonprofit associate' do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it 'rejects other admin' do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'rejects other associate' do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'rejects campaign editor' do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it 'rejects confirmed user' do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it 'reject event editor' do
    reject(event_editor, method, action, *fixed_args)
  end

  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'rejects profile user' do
    reject(user_with_profile, method, action, *fixed_args)
  end
end


RSpec.shared_context :open_to_profile_owner do |method, action, *args|
  include_context :shared_user_context
  let(:fixed_args){
    fix_args( *args)
  }

  it 'rejects no user' do
    reject(nil, method, action, *fixed_args)
  end

  it 'rejects user with no roles' do
    reject(unauth_user, method, action, *fixed_args)
  end

  it 'rejects nonprofit admin' do
    reject(user_as_np_admin, method, action, *fixed_args)
  end

  it 'rejects nonprofit associate' do
    reject(user_as_np_associate, method, action, *fixed_args)
  end

  it 'rejects other admin' do
    reject(user_as_other_np_admin, method, action, *fixed_args)
  end

  it 'rejects other associate' do
    reject(user_as_other_np_associate, method, action, *fixed_args)
  end

  it 'rejects campaign editor' do
    reject(campaign_editor, method, action, *fixed_args)
  end

  it 'rejects confirmed user' do
    reject(confirmed_user, method, action, *fixed_args)
  end

  it 'reject event editor' do
    reject(event_editor, method, action, *fixed_args)
  end

  it 'accepts super admin' do
    accept(super_admin, method, action, *fixed_args)
  end

  it 'accepts profile user' do
    accept(user_with_profile, method, action, *fixed_args)
  end
end