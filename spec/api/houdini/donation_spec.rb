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
      input = {donation: {address:{address: "heothwohtw"}}}
      xhr :put, '/api/v1/donation/410595', input
      expect(response.code).to eq "404"
    end

    describe 'authorize properly' do

      it '401s properly' do
        nonprofit.miscellaneous_np_info = MiscellaneousNpInfo.new(supporter_default_address_strategy: :manual)
        nonprofit.miscellaneous_np_info.save!
        nonprofit.save!
        #nonprofit.miscellaneous_np_info.supporter_default_address_strategy = :manual
        run_authorization_tests({method: :put, action: "/api/v1/donation/#{donation.id}",
                                 successful_users:  roles__open_to_np_associate}) do |u|
          {donation: {address:{address: "heothwohtw"}}}
        end

      end



    end

    describe 'param validation' do

      before(:each) do
        sign_in user_as_np_admin

      end
      it 'donation is the root element' do

        xhr :put, "/api/v1/donation/#{donation.id}", {}
        expect(response.status).to eq 400

        expected_errors = {
            errors:
                [
                    h(params: ["donation"], messages: grape_error("presence"))
                ]


        }
        expect_validation_errors(JSON.parse(response.body), expected_errors)
      end


      it 'address is invalid' do

        xhr :put, "/api/v1/donation/#{donation.id}", {donation:{address: 'something'}}
        expect(response.status).to eq 400
        expected_errors = {
            errors:
                [
                    h(params: ["donation[address]"], messages: grape_error("coerce"))
                ]


        }
        expect_validation_errors(JSON.parse(response.body), expected_errors)
      end

      it 'address details are invalid' do

        xhr :put, "/api/v1/donation/#{donation.id}",
            {
              donation:
                  {
                      address:
                          {
                            address: [""], city: [""], state_code: [""], zip_code: [""], country: [""]
                          }
                  }
            }
        expect(response.status).to eq 400
        expected_errors = {
            errors:
            %w(address city state_code zip_code country).map {|i| h(params: ["donation[address][#{i}]"], messages: grape_error("coerce"))}
        }
        expect_validation_errors(JSON.parse(response.body), expected_errors)
      end
    end


    describe 'update donations' do

      before(:each) { nonprofit.miscellaneous_np_info = MiscellaneousNpInfo.new(supporter_default_address_strategy: :manual)
      nonprofit.miscellaneous_np_info.save!
      nonprofit.save!
      sign_in user_as_np_admin
      }
      let(:input) do
        {donation: {address: {
            address: 'adddress',
            city: 'cityeee',
            state_code:"state code",
            zip_code: "532525",
            country: 'coutnwet'
        }}}
      end


      let(:input_address) { input[:donation][:address]}

      def generate_expected()
          return h({id: donation.id,
             address:
                 h({
                       id: TransactionAddress.last.id,
                       address: input_address[:address],
                       city: input_address[:city],
                       state_code: input_address[:state_code],
                       zip_code: input_address[:zip_code],
                       country: input_address[:country],
                       fingerprint: AddressComparisons.calculate_hash(donation.supporter.id, input_address[:address],
                                                                      input_address[:city],
                                                                      input_address[:state_code],
                                                                      input_address[:zip_code],
                                                                      input_address[:country]),
                       type: "TransactionAddress",
                       name: nil,
                       supporter: h({id: donation.supporter.id})
                   })
            })


      end

      def make_call_and_verify_response
        xhr :put, "/api/v1/donation/#{donation.id}", input, format: :json
        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)


        expected = generate_expected


        expect(json_response).to eq expected
      end

      it 'no address already' do

        # make sure on add is called
        expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_add)
        make_call_and_verify_response()

      end


      describe 'an identical address is in the db' do

        let(:address_matching_input) { TransactionAddress.create!({supporter: donation.supporter}.merge(input_address))}

        let(:pre_input_address) {TransactionAddress.create!({supporter: donation.supporter}.merge(input_address).merge({country: 'ehtwetioh'})) }

        before(:each) do
          # just some address we're not going to have any more
          donation.address = pre_input_address
          donation.address.save!
          donation.save!
          address_matching_input
        end

        it 'but its not used by anything else' do

          expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_use)
          expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_remove).with(donation.supporter, pre_input_address)
          make_call_and_verify_response()


          donation.reload
          expect(donation.address).to eq address_matching_input
          expect(Address.where(id: pre_input_address.id).any?).to be_falsey
        end

        it 'used by another transaction so we dont delete the original address' do

          AddressToTransactionRelation.create!(address: pre_input_address)
          expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_use)
          expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to_not receive(:on_remove)
          make_call_and_verify_response()


          donation.reload
          expect(donation.address).to eq address_matching_input
          expect(Address.where(id: pre_input_address.id).any?).to be_truthy
        end
      end
      it 'address already set exists but identical' do


        original_address = TransactionAddress.create!({supporter: donation.supporter}.merge(input_address))
        donation.address = original_address
        donation.address.save!
        donation.save!

        # make sure on add is called
        expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_use)
        make_call_and_verify_response()


        donation.reload
        expect(donation.address).to eq original_address

      end
    end


  end
end