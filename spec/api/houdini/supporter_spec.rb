# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'api/support/api_shared_user_verification'
require 'support/api_errors'
include ExpectApi
describe Houdini::V1::Supporter, :type => :request do

  describe '/:supporter_id' do
    include_context :shared_donation_charge_context
    include_context :api_shared_user_verification
    describe :get do

      let(:default_address) do
        create(:address,
               supporter: supporter,
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
                                 successful_users: roles__open_to_np_associate})
      end

      it 'returns supporter if its there' do
        UpdateAddressTags::set_default_address(supporter, default_address)
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
                state_code: default_address.state_code,
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

    describe :put do
      let(:custom_address) do
        create(:address,
               supporter: supporter,
               type: 'CustomAddress',
               address: 'address1',
               city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")

      end

      let (:custom_address2) do
        create(:address,
               supporter: other_supporter,
               type: 'CustomAddress',
               address: 'address2',
               city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
      end
      let(:transaction_address) do
        create(:address,
               supporter: supporter,
               type: 'TransactionAddress',
               address: 'address3',
               city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
      end

      before(:each) do
        custom_address
        custom_address2
        transaction_address
      end

      it 'should allow np associated people through but no one else' do
        run_authorization_tests({method: :put, action: "/api/v1/supporter/#{supporter.id}",
                                 successful_users: roles__open_to_np_associate})
      end

      describe 'invalid entity check' do
        it 'should 404 when the supporter is missing' do
          sign_in user_as_np_admin

          xhr :put, "/api/v1/supporter/99999"
          expect(response.status).to eq 404
        end

        it 'should 404 when the default_address set is not valid' do
          sign_in user_as_np_admin
          xhr :put, "/api/v1/supporter/#{supporter.id}", supporter: {default_address: {id: 99999}}
          expect(response.status).to eq 404
        end

        it 'should 404 when the default_address set is not from current supporter' do
          sign_in user_as_np_admin
          xhr :put, "/api/v1/supporter/#{supporter.id}", supporter: {default_address: {id: custom_address2.id}}
          expect(response.status).to eq 404
        end
      end

      it 'should update nothing when default_address isnt provided' do
        sign_in user_as_np_admin

        expect_any_instance_of(Supporter).to_not receive(:default_address_strategy)
        xhr :put, "/api/v1/supporter/#{supporter.id}"

        expect(response.status).to eq 200
      end

      it 'should update default_address when provided' do
        sign_in user_as_np_admin

        address_strategy = double("address_strategy")
        expect(address_strategy).to receive(:on_modify_default_request)

        expect_any_instance_of(Supporter).to receive(:default_address_strategy).and_return(address_strategy)
        xhr :put, "/api/v1/supporter/#{supporter.id}", supporter: {default_address: {id: custom_address.id}}

        expect(response.status).to eq 200

        json_response = JSON::parse(response.body)
        # the result is dependant on what default_address_strategy is used
        expected = {
            'id'=> supporter.id,
            'default_address'=> nil
        }

        expect(json_response).to eq expected
      end
    end

    describe "/address" do
      include_context :shared_donation_charge_context
      include_context :api_shared_user_verification

      let (:address_strategy_mock) do
        address_strategy = double("address_strategy")
        allow(address_strategy).to receive(:on_add)
        allow_any_instance_of(Supporter).to receive(:default_address_strategy).and_return(address_strategy)
        address_strategy
      end
      describe 'list all' do
        include_context :shared_donation_charge_context
        include_context :api_shared_user_verification
        it ' should allow np associated people through but no one else' do
          run_authorization_tests({method: :get, action: "/api/v1/supporter/#{supporter.id}/address",
                                   successful_users: roles__open_to_np_associate})
        end

        describe 'validate parameters' do
          before(:each) {sign_in user_as_np_admin}
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

                expect(json_response['errors']).to include(h(params: ['page_number'], messages: grape_error({key: :greater_than_or_equal, options: {value: 0}})))
              end
            end

            describe 'page_length' do
              it 'should be at least 1' do
                xhr :get, "/api/v1/supporter/#{supporter.id}/address", {page_length: 0}

                json_response = JSON.parse(response.body)
                expect(response.status).to eq 400

                expect(json_response['errors']).to include(h(params: ['page_length'], messages: grape_error({key: :greater_than_or_equal, options: {value: 1}})))
              end

              it 'should be no more than 100' do
                xhr :get, "/api/v1/supporter/#{supporter.id}/address", {page_length: 101}

                json_response = JSON.parse(response.body)
                expect(response.status).to eq 400

                expect(json_response['errors']).to include(h(params: ['page_length'], messages: grape_error({key: :less_than_or_equal, options: {value: 100}})))
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

              expect(json_response['errors']).to include(h(params: ['type'], messages: grape_error(:values)))
            end
          end
        end

        it 'should 404 when the supporter is missing' do
          sign_in user_as_np_admin
          xhr :get, "/api/v1/supporter/99999/address"
          expect(response.status).to eq 404
        end

        describe 'list gets correct items' do
          before(:each) {sign_in user_as_np_admin}

          let(:custom_address) do
            create(:address,
                   supporter: supporter,
                   type: 'CustomAddress',
                   address: 'address1',
                   city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")

          end

          let (:custom_address2) do
            create(:address,
                   supporter: supporter,
                   type: 'CustomAddress',
                   address: 'address2',
                   city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
          end
          let(:transaction_address) do
            create(:address,
                   supporter: supporter,
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


      describe 'post' do
        it 'should allow np associated people through but no one else' do
          run_authorization_tests({method: :post, action: "/api/v1/supporter/#{supporter.id}/address",
                                   successful_users: roles__open_to_np_associate}) {{address: {address: 'input'}}}
        end

        it 'should require at least one of the fields to be filled' do
          xhr :post, "/api/v1/supporter/99999/address"

          expect(response.status).to be 400

          json_response = JSON::parse(response.body)

          expected = [h(params: ["address"], messages: grape_error("presence")),
                      h(params: ["address[address]", "address[city]", "address[state_code]", "address[zip_code]", "address[country]"], messages: grape_error("at_least_one")),
          ]

          expect(json_response['errors']).to eq expected
        end

        describe 'missing entity' do
          it 'should 404 when the supporter is missing' do
            sign_in user_as_np_admin

            xhr :post, "/api/v1/supporter/99999/address", address: {address: 'input'}
            expect(response.status).to eq 404
          end
        end

        it 'should create and return a new CustomAddress' do
          address_strategy = double("address_strategy")
          expect(address_strategy).to receive(:on_add).once
          expect_any_instance_of(Supporter).to receive(:default_address_strategy).and_return(address_strategy)

          input = {'address' => 'input', 'city' => 'city', 'state_code' => 'state_code', 'zip_code' => 'zip_code', 'country' => 'country place'}

          sign_in user_as_np_admin

          xhr :post, "/api/v1/supporter/#{supporter.id}/address", address: input
          expect(response.status).to eq 201

          json_response = JSON::parse(response.body)


          expected = input.merge({
                                     'id' => CustomAddress.last.id,
                                     'supporter' => {
                                         'id' => supporter.id
                                     },
                                     'fingerprint' => CustomAddress.last.fingerprint,
                                     'name' => nil,
                                     'type' => 'CustomAddress'
                                 })
          expect(json_response).to eq expected
        end
      end

      describe '/:custom_address_id' do
        let(:address) do
          create(:address,
                 supporter: supporter,
                 type: 'CustomAddress',
                 address: 'address',
                 city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
        end


        let(:transaction_address) do
          create(:address,
                 supporter: supporter,
                 type: 'TransactionAddress',
                 address: 'address',
                 city: "city", state_code: "wi", zip_code: "zippy zip", country: "country")
        end

        let (:other_supporter_address) do
          create(:address,
                 supporter: other_supporter,
                 type: 'TransactionAddress',
                 address: 'address2',
                 city: "city2", state_code: "wi2", zip_code: "zippy zip2", country: "country2")
        end

        describe 'get' do
          it 'should allow np associated people through but no one else' do
            run_authorization_tests({method: :get, action: "/api/v1/supporter/#{supporter.id}/address/#{address.id}",
                                     successful_users: roles__open_to_np_associate})
          end

          describe 'missing entity' do
            it 'should 404 when the supporter is missing' do
              sign_in user_as_np_admin
              xhr :get, "/api/v1/supporter/99999/address/9999"
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is missing' do
              sign_in user_as_np_admin
              xhr :get, "/api/v1/supporter/#{supporter.id}/address/99999"
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is for the wrong supporter' do
              sign_in user_as_np_admin
              xhr :get, "/api/v1/supporter/#{other_nonprofit_supporter.id}/address/#{other_supporter_address.id}"
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is TransactionAddress' do
              sign_in user_as_np_admin
              xhr :get, "/api/v1/supporter/#{other_nonprofit_supporter.id}/address/#{transaction_address.id}"
              expect(response.status).to eq 404
            end
          end

          it 'should return the correct address' do
            sign_in user_as_np_admin
            xhr :get, "/api/v1/supporter/#{supporter.id}/address/#{address.id}"
            expect(response.status).to eq 200

            json_response = JSON::parse(response.body)

            expected = h({
                             id: address.id,
                             address: address.address,
                             city: address.city,
                             state_code: address.state_code,
                             zip_code: address.zip_code,
                             country: address.country,
                             name: address.name,
                             fingerprint: address.fingerprint,
                             type: address.type,
                             supporter: h(
                                 {
                                     id: supporter.id
                                 })
                         })

            expect(json_response).to eq expected

          end
        end
        describe 'put' do
          describe 'missing entity' do
            it 'should 404 when the supporter is missing' do
              sign_in user_as_np_admin
              xhr :put, "/api/v1/supporter/99999/address/99999", address: {address: 'twoehtowit'}
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is missing' do
              sign_in user_as_np_admin
              xhr :put, "/api/v1/supporter/#{supporter.id}/address/99999", address: {address: 'twoehtowit'}
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is for the wrong supporter' do
              sign_in user_as_np_admin
              xhr :put, "/api/v1/supporter/#{other_nonprofit_supporter.id}/address/#{other_supporter_address.id}", address: {address: 'twoehtowit'}
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is TransactionAddress' do
              sign_in user_as_np_admin
              xhr :put, "/api/v1/supporter/#{other_nonprofit_supporter.id}/address/#{transaction_address.id}", address: {address: 'twoehtowit'}
              expect(response.status).to eq 404
            end
          end

          it 'should allow np associated people through but no one else' do
            run_authorization_tests({method: :put, action: "/api/v1/supporter/#{supporter.id}/address/#{address.id}",
                                     successful_users: roles__open_to_np_associate}) {{address: {address: 'input'}}}
          end

          it 'should update the address' do
            address_strategy = double("address_strategy")
            expect(address_strategy).to receive(:on_use).once
            expect_any_instance_of(Supporter).to receive(:default_address_strategy).and_return(address_strategy)

            input = {'address' => 'input', 'city' => 'city', 'state_code' => 'state_code', 'zip_code' => 'zip_code', 'country' => 'country place'}

            sign_in user_as_np_admin

            xhr :put, "/api/v1/supporter/#{supporter.id}/address/#{address.id}", address: input
            expect(response.status).to eq 200

            json_response = JSON::parse(response.body)


            expected = input.merge({
                                       'id' => address.id,
                                       'supporter' => {
                                           'id' => supporter.id
                                       },
                                       'fingerprint' => CustomAddress.last.fingerprint,
                                       'name' => nil,
                                       'type' => 'CustomAddress'
                                   })
            expect(json_response).to eq expected
          end
        end

        describe 'delete' do
          describe 'missing entity' do
            it 'should 404 when the supporter is missing' do
              sign_in user_as_np_admin
              xhr :delete, "/api/v1/supporter/99999/address/99999"
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is missing' do
              sign_in user_as_np_admin
              xhr :delete, "/api/v1/supporter/#{supporter.id}/address/99999"
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is for the wrong supporter' do
              sign_in user_as_np_admin
              xhr :delete, "/api/v1/supporter/#{other_nonprofit_supporter.id}/address/#{other_supporter_address.id}"
              expect(response.status).to eq 404
            end

            it 'should 404 when the address is TransactionAddress' do
              sign_in user_as_np_admin
              xhr :delete, "/api/v1/supporter/#{other_nonprofit_supporter.id}/address/#{transaction_address.id}"
              expect(response.status).to eq 404
            end
          end

          it 'should allow np associated people through but no one else' do
            run_authorization_tests({method: :delete, action: "/api/v1/supporter/#{supporter.id}/address/#{address.id}",
                                     successful_users: roles__open_to_np_associate})
          end

          it 'should delete the address' do
            address_strategy = double("address_strategy")
            expect(address_strategy).to receive(:on_remove).once
            expect_any_instance_of(Supporter).to receive(:default_address_strategy).and_return(address_strategy)


            sign_in user_as_np_admin

            address
            xhr :delete, "/api/v1/supporter/#{supporter.id}/address/#{address.id}"
            expect(response.status).to eq 200

            json_response = JSON::parse(response.body)

            expected = {
                'id' => address.id,
                'supporter' => {
                    'id' => supporter.id
                },
                'fingerprint' => address.fingerprint,
                'name' => nil,
                'type' => 'CustomAddress',
                'address' => address.address,
                'city' => address.city,
                'state_code' => address.state_code,
                'zip_code' => address.zip_code,
                'country' => address.country
            }
            expect(json_response).to eq expected
          end
        end
      end
    end
  end
end



