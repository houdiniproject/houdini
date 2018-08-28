# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Houdini::V1::Donation, :type => :request do
   include_context :shared_donation_charge_context
  # include_context :request_access_verifier
  let(:transaction_address) do
    create(:address,
             supporter:supporter,
             type: 'TransactionAddress',
             address: 'address',
             city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
  end

  let(:donation) do
    force_create(:donation, nonprofit: nonprofit, supporter:supporter, amount:2000)
  end
  describe :get do
    it '404s on invalid address' do
      xhr :get, '/api/v1/donation/410595'
      expect(response.code).to eq "404"
    end

    describe 'authorize properly' do

      describe '401s properly' do
        let (:action){
          "/api/v1/donation/#{donation.id}"
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
          reject(user_to_signin:user_as_other_np_admin, method:method, action:action, args:fixed_args, status:401)
        end

        it 'rejects other associate' do
          reject(user_to_signin:user_as_other_np_associate, method:method, action:action, args:fixed_args, status:401)
        end

        it 'rejects campaign editor' do
          reject(user_to_signin:campaign_editor, method:method, action:action, args:fixed_args, status:401)
        end

        it 'rejects confirmed user' do
          reject(user_to_signin:confirmed_user, method:method, action:action, args:fixed_args, status:401)
        end

        it 'reject event editor' do
          reject(user_to_signin:event_editor, method:method, action:action, args:fixed_args, status:401)
        end

        it 'accepts super admin' do
          accept(user_to_signin:super_admin, method:method, action:action, args:fixed_args)
        end

        it 'rejects profile user' do
          reject(user_to_signin:user_with_profile, method:method, action:action, args:fixed_args, status:401)
        end


      end
    end


    it 'returns donation' do
      donation.address = transaction_address
      donation.save!

      sign_in user_as_np_admin
      xhr :get, "/api/v1/donation/#{donation.id}"

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expected = {
          id: donation.id,
          address: {
              id: transaction_address.id,
              address: transaction_address.address,
              city: transaction_address.city,
              state_code:transaction_address.state_code,
              zip_code: transaction_address.zip_code,
              country: transaction_address.country,
              name: transaction_address.name,
              fingerprint: transaction_address.fingerprint,
              type: transaction_address.type,
              supporter: {
                  id: supporter.id
              }.with_indifferent_access
          }.with_indifferent_access
      }.with_indifferent_access

      expect(json_response).to eq expected.to_hash

    end
  end

  describe :put do
    it '404s on invalid address' do
      xhr :put, '/api/v1/donation/410595'
      expect(response.code).to eq "404"
    end

    describe 'authorize properly' do

      describe '401s properly' do
        let (:action){
          "/api/v1/donation/#{donation.id}"
        }
        let(:method){
          :put
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
          reject(user_to_signin:user_as_other_np_admin, method:method, action:action, args:fixed_args, status:401)
        end

        it 'rejects other associate' do
          reject(user_to_signin:user_as_other_np_associate, method:method, action:action, args:fixed_args, status:401)
        end

        it 'rejects campaign editor' do
          reject(user_to_signin:campaign_editor, method:method, action:action, args:fixed_args, status:401)
        end

        it 'rejects confirmed user' do
          reject(user_to_signin:confirmed_user, method:method, action:action, args:fixed_args, status:401)
        end

        it 'reject event editor' do
          reject(user_to_signin:event_editor, method:method, action:action, args:fixed_args, status:401)
        end

        it 'accepts super admin' do
          accept(user_to_signin:super_admin, method:method, action:action, args:fixed_args)
        end

        it 'rejects profile user' do
          reject(user_to_signin:user_with_profile, method:method, action:action, args:fixed_args, status:401)
        end


      end
    end

    it 'param validation' do
      input = {}
      xhr :put, "/api/v1/donation/#{donation.id}", input

      expect(response.status).to eq 400

    end

    describe 'update donations' do
      it 'no address already' do
        donation.address = transaction_address
        donation.save!

        # donation: {
        #     address: {}
        sign_in user_as_np_admin
        xhr :put, "/api/v1/donation/#{donation.id}", format: :json
      end
    end

    it 'updates donation' do


      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)
    end
  end
end