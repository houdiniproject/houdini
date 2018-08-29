# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'api/support/api_shared_user_verification'
require 'support/api_errors'
describe Houdini::V1::Donation, :type => :request do
   include_context :shared_donation_charge_context
   include_context :api_shared_user_verification
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

      it '401s properly' do
        run_authorization_tests({method: :get, action: "/api/v1/donation/#{donation.id}",
                                 successful_users:  roles__open_to_np_associate})

      end
    end

    it 'returns donation with address' do
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

    it 'returns donation without address' do

      sign_in user_as_np_admin
      xhr :get, "/api/v1/donation/#{donation.id}"

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expected = {
          id: donation.id,
          address: nil
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

      it '401s properly' do
        run_authorization_tests({method: :put, action: "/api/v1/donation/#{donation.id}",
                                 successful_users:  roles__open_to_np_associate})

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