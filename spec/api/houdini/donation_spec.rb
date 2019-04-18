# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'api/support/api_shared_user_verification'
require 'support/api_errors'
include ExpectApi
describe Houdini::V1::Donation, :type => :request do
  include_context :shared_donation_charge_context
  include_context :api_shared_user_verification
  let(:transaction_address) do
    create(:transaction_address,
             supporter:supporter,
             address: 'address',
             city: "city", state_code: "wi", zip_code: "zippy zip", country: "country", transactionable:donation)
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
      transaction_address

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
              fingerprint: transaction_address.fingerprint,
              supporter: {
                  id: supporter.id
              }.with_indifferent_access,
              updated_at: Time.now
          }.with_indifferent_access
      }.with_indifferent_access

      expect(expected.to_hash).to eq json_response

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
                    h(params: ["donation"], messages: grape_error(:presence))
                ]


        }
        expect_api_validation_errors(JSON.parse(response.body), expected_errors)
      end


      it 'address is invalid' do

        xhr :put, "/api/v1/donation/#{donation.id}", {donation:{address: 'something'}}
        expect(response.status).to eq 400
        expected_errors = {
            errors:
                [
                    h(params: ["donation[address]"], messages: grape_error(:coerce))
                ]


        }
        expect_api_validation_errors(JSON.parse(response.body), expected_errors)
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
            %w(address city state_code zip_code country).map {|i| h(params: ["donation[address][#{i}]"], messages: grape_error(:coerce))}
        }
        expect_api_validation_errors(JSON.parse(response.body), expected_errors)
      end
    end


    describe 'update donations' do

      before(:each) {
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
                       supporter: h({id: donation.supporter.id}),
                       updated_at: Time.now
                   })
            })


      end

      def make_call_and_verify_response
        xhr :put, "/api/v1/donation/#{donation.id}", input, format: :json
        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)


        expected = generate_expected


        expect(expected).to eq json_response
      end

      it 'no address already' do
        make_call_and_verify_response
      end

      it 'address is modified' do
          id = donation.create_address!(address: "something", supporter: donation.supporter).id
          make_call_and_verify_response

          expect(TransactionAddress.last.id).to eq id
      end
    end


  end
end