module AccessVerificationTests
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
  
  def open_to_all(method, action)

    let(:fixed_args){
      fix_args( *args)
    }

    it 'verifier.accepts no user' do
      verifier.accept(nil, method, action, *fixed_args)
    end

    it 'verifier.accepts user with no roles' do
      verifier.accept(unauth_user, method, action, *fixed_args)
    end

    it 'verifier.accepts nonprofit admin' do
      verifier.accept(user_as_np_admin, method, action, *fixed_args)
    end

    it 'verifier.accepts nonprofit associate' do
      verifier.accept(user_as_np_associate, method, action, *fixed_args)
    end

    it 'verifier.accepts other admin' do
      verifier.accept(user_as_other_np_admin, method, action, *fixed_args)
    end

    it 'verifier.accepts other associate' do
      verifier.accept(user_as_other_np_associate, method, action, *fixed_args)
    end

    it 'verifier.accepts campaign editor' do
      verifier.accept(campaign_editor, method, action, *fixed_args)
    end

    it 'verifier.accept confirmed user' do
      verifier.accept(confirmed_user, method, action, *fixed_args)
    end

    it 'verifier.accept event editor' do
      verifier.accept(event_editor, method, action, *fixed_args)
    end

    it 'verifier.accepts super admin' do
      verifier.accept(super_admin, method, action, *fixed_args)
    end

    it 'verifier.accept profile user' do
      verifier.accept(user_with_profile, method, action, *fixed_args)
    end
  end
end