require 'rails_helper'
class AccessVerifier

  attr_accessor :nonprofit, :other_nonprofit

  def initialize(args={})
    @nonprofit =  args[:nonprofit] || force_create(:nonprofit, published:true)

    @nonprofit = args[:other_nonprofit] || force_create(:nonprofit)



    @user_as_np_admin = __create_admin(nonprofit)


    @user_as_np_admin
      __create_admin(other_nonprofit)


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
  end



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

  def accept(*args)
    raise NotImplementedError
  end

  def reject(*args)
    raise NotImplementedError
  end

end