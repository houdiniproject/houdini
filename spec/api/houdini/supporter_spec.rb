# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'api/support/api_shared_user_verification'
require 'support/api_errors'
include ExpectApi
describe Houdini::V1::Supporter, :type => :request do

  describe :get do
    include_context :shared_donation_charge_context
    include_context :api_shared_user_verification

    let(:default_address) do
      create(:address,
             supporter:supporter,
             type: 'TransactionAddress',
             address: 'address',
             city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
    end

   it 'returns 404 if supporter is missing' do
     xhr :get, "/api/v1/supporter/99999"
     expect(response.status).to eq 404
   end

   it 'returns 401 if unauthorized' do
     run_authorization_tests({method: :get, action: "/api/v1/supporter/#{supporter.id}",
                              successful_users:  roles__open_to_np_associate})
   end

    it 'returns supporter if its there' do
      UpdateAddressTags::set_default_address(supporter,default_address)
      sign_in user_as_np_admin
      xhr :get, "/api/v1/supporter/#{supporter.id}"

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expected = {
        id: supporter.id,
        default_address: {
            id: default_address.id,
            address: default_address.address,
            city: default_address.city,
            state_code:default_address.state_code,
            zip_code: default_address.zip_code,
            country: default_address.country,
            name: default_address.name,
            fingerprint: default_address.fingerprint,
            type: default_address.type,
            supporter: {
                id: supporter.id
            }.with_indifferent_access
        }.with_indifferent_access
      }.with_indifferent_access

      expect(json_response).to eq expected.to_hash
    end

  end

  describe "/address" do
    describe 'list all' do
      include_context :shared_donation_charge_context
      include_context :api_shared_user_verification
      it ' should allow np associated people through but no one else' do
        run_authorization_tests({method: :get, action: "/api/v1/supporter/#{supporter.id}/address",
                                 successful_users:  roles__open_to_np_associate})
      end

      describe 'validate parameters' do
        before(:each) { sign_in user_as_np_admin}
        it 'should have correct defaults for page number and length' do

          xhr :get, "/api/v1/supporter/#{supporter.id}/address"

          json_response = JSON.parse(response.body)
          expect(json_response['page_number']).to eq 0
          expect(json_response['page_length']).to eq 20
        end

        it 'should accept correct numbers for page number and length' do

          xhr :get, "/api/v1/supporter/#{supporter.id}/address", {page_number: 1, page_length: 30}

          json_response = JSON.parse(response.body).with_indifferent_access
          expect(json_response['page_number']).to eq 1
          expect(json_response['page_length']).to eq 30
        end

        describe 'rejects invalid parameters' do
          describe 'page number' do
            it 'should be at least 0' do
              xhr :get, "/api/v1/supporter/#{supporter.id}/address", {page_number: -1}

              json_response = JSON.parse(response.body)
              expect(response.status).to eq 400

              expect(json_response['errors']).to include(h(params:['page_number'], messages: grape_error({key: :greater_than_or_equal, options: {value: 0}})))
            end
          end

          describe 'page_length' do
            it 'should be at least 1' do
              xhr :get, "/api/v1/supporter/#{supporter.id}/address", {page_length: 0}

              json_response = JSON.parse(response.body)
              expect(response.status).to eq 400

              expect(json_response['errors']).to include(h(params:['page_length'], messages: grape_error({key: :greater_than_or_equal, options: {value: 1}})))
            end

            it 'should be no more than 100' do
              xhr :get, "/api/v1/supporter/#{supporter.id}/address", {page_length: 101}

              json_response = JSON.parse(response.body)
              expect(response.status).to eq 400

              expect(json_response['errors']).to include(h(params:['page_length'], messages: grape_error({key: :less_than_or_equal, options: {value: 100}})))
            end
          end
        end

        describe 'type' do
          it 'should accept ALL' do
            xhr :get, "/api/v1/supporter/#{supporter.id}/address", {type: 'ALL'}

            json_response = JSON.parse(response.body)
            expect(response.status).to eq 200


          end

          it 'should accept CUSTOM' do
            xhr :get, "/api/v1/supporter/#{supporter.id}/address", {type: 'CUSTOM'}

            json_response = JSON.parse(response.body)
            expect(response.status).to eq 200


          end

          it 'should reject other values' do
            xhr :get, "/api/v1/supporter/#{supporter.id}/address", {type: 'INVALID VALUE CUSTOM'}

            json_response = JSON.parse(response.body)
            expect(response.status).to eq 400

            expect(json_response['errors']).to include(h(params:['type'], messages:grape_error(:values)))
          end
        end
      end

      it 'should 404 when the supporter is missing' do
        sign_in user_as_np_admin
        xhr :get, "/api/v1/supporter/99999/address"
        expect(response.status).to eq 404
      end

      describe 'list gets correct items' do
        before(:each) { sign_in user_as_np_admin}

        let(:custom_address) do
          create(:address,
                 supporter:supporter,
                 type: 'CustomAddress',
                 address: 'address1',
                 city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")

        end

        let (:custom_address2) do
          create(:address,
                 supporter:supporter,
                 type: 'CustomAddress',
                 address: 'address2',
                 city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
        end
        let(:transaction_address) do
          create(:address,
                 supporter:supporter,
                 type: 'TransactionAddress',
                 address: 'address3',
                 city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
        end

        before(:each) do
          custom_address
          custom_address2
          transaction_address
        end

        it 'should return all addresses' do
          xhr :get, "/api/v1/supporter/#{supporter.id}/address", type: "ALL"
          json_response = JSON.parse(response.body)
          expect(json_response['page_number']).to eq 0
          expect(json_response['page_length']).to eq 20
          expect(json_response['total']).to eq 3
          expect(json_response['addresses'].count).to eq 3
        end

        it 'should return custom' do
          xhr :get, "/api/v1/supporter/#{supporter.id}/address", type: "CUSTOM"
          json_response = JSON.parse(response.body)
          expect(json_response['page_number']).to eq 0
          expect(json_response['page_length']).to eq 20
          expect(json_response['total']).to eq 2
          expect(json_response['addresses'].count).to eq 2
        end

      end
    end
  end
end



