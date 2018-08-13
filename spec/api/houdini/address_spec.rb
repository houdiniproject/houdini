# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Houdini::V1::Address, :type => :request do
  include_context :shared_donation_charge_context

  describe :get do
    it '404s on invalid address' do
      xhr :get, '/api/v1/address/410595'
      expect(response.code).to eq "404"
    end

    describe 'authorization properly' do
      include_context :request_access_verifier
      describe '401s properly' do
        let (:action){
          "/api/v1/address/#{supporter_address.id}"
        }
        let(:method){
          :get
        }

        let (:fixed_args) {
            Array.new()
        }



        it 'rejects no user' do
          reject(user_to_signin:nil, method:method, action:action, args:fixed_args, status:401)
        end

        it 'rejects user with no roles' do
          reject(user_to_signin:unauth_user, method:method, action:action, args:fixed_args, status:401)
        end

        it 'accepts nonprofit admin' do
          accept(user_to_signin:user_as_np_admin, method:method, action:action, args:fixed_args)
        end

        it 'accepts nonprofit associate' do
          accept(user_to_signin:user_as_np_associate, method:method, action:action, args:fixed_args)
        end

        it 'rejects other admin' do
          reject(user_to_signin:user_as_other_np_admin, method:method, action:action, args:fixed_args)
        end

        it 'rejects other associate' do
          reject(user_to_signin:user_as_other_np_associate, method:method, action:action, args:fixed_args)
        end

        it 'rejects campaign editor' do
          reject(user_to_signin:campaign_editor, method:method, action:action, args:fixed_args)
        end

        it 'rejects confirmed user' do
          reject(user_to_signin:confirmed_user, method:method, action:action, args:fixed_args)
        end

        it 'reject event editor' do
          reject(user_to_signin:event_editor, method:method, action:action, args:fixed_args)
        end

        it 'accepts super admin' do
          accept(user_to_signin:super_admin, method:method, action:action, args:fixed_args)
        end

        it 'rejects profile user' do
          reject(user_to_signin:user_with_profile, method:method, action:action, args:fixed_args)
        end

        #include_context :open_to_np_associate, :get, "/api/v1/address/#{supporter_address.id}}"
      end
    end
  end
end