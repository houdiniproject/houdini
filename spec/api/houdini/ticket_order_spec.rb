# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'api/support/api_shared_user_verification'
require 'support/api_errors'
include ExpectApi
describe Houdini::V1::TicketOrder, :type => :request do
  include_context :shared_donation_charge_context
  include_context :api_shared_user_verification
  let(:transaction_address) do
    create(:transaction_address,
             supporter:supporter,
             address: 'address',
             city: "city", state_code: "wi", zip_code: "zippy zip", country: "country", transactionable: ticket_order)
  end

  let(:ticket_order) do
    force_create(:ticket_order, supporter: supporter)
  end

  let!(:ticket) {
    force_create(:ticket, ticket_order: ticket_order, event: event)
  }
  describe :get do
    it '404s on invalid address' do
      xhr :get, '/api/v1/ticket_order/410595'
      expect(response.code).to eq "404"
    end

    describe 'authorize properly' do

      it '401s properly' do
        run_authorization_tests({method: :get, action: "/api/v1/ticket_order/#{ticket_order.id}",
                                 successful_users:  roles__open_to_event_editor})

      end
    end

    it 'returns ticket order with address' do
      transaction_address

      sign_in user_as_np_admin
      xhr :get, "/api/v1/ticket_order/#{ticket_order.id}"

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expected = h({
          id: ticket_order.id,
          address: h({
              id: transaction_address.id,
              address: transaction_address.address,
              city: transaction_address.city,
              state_code:transaction_address.state_code,
              zip_code: transaction_address.zip_code,
              country: transaction_address.country,
              fingerprint: transaction_address.fingerprint,
              supporter: h({
                  id: supporter.id
              }),
              updated_at: Time.now
          }),
          supporter: h({id: supporter.id})
      })

      expect(expected.to_hash).to eq json_response

    end

    it 'returns ticket order without address' do

      sign_in user_as_np_admin
      xhr :get, "/api/v1/ticket_order/#{ticket_order.id}"

      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)

      expected = {
          id: ticket_order.id,
          supporter: h({id: supporter.id}),
          address: nil
      }.with_indifferent_access

      expect(json_response).to eq expected.to_hash

    end
  end

  describe :put do
    it '404s on invalid address' do
      input = {ticket_order: {address:{address: "heothwohtw"}}}
      xhr :put, '/api/v1/ticket_order/410595', input
      expect(response.code).to eq "404"
    end

    describe 'authorize properly' do

      it '401s properly' do
       
        run_authorization_tests({method: :put, action: "/api/v1/ticket_order/#{ticket_order.id}",
                                 successful_users:  roles__open_to_event_editor}) do |u|
          {ticket_order: {address:{address: "heothwohtw"}}}
        end

      end



    end

    describe 'param validation' do

      before(:each) do
        sign_in user_as_np_admin

      end

      it 'address is invalid' do

        xhr :put, "/api/v1/ticket_order/#{ticket_order.id}", {ticket_order:{address: 'something'}}
        expect(response.status).to eq 400
        expected_errors = {
            errors:
                [
                    h(params: ["ticket_order[address]"], messages: grape_error("coerce"))
                ]


        }
        expect_api_validation_errors(JSON.parse(response.body), expected_errors)
      end

      it 'address details are invalid' do

        xhr :put, "/api/v1/ticket_order/#{ticket_order.id}",
            {
              ticket_order:
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
            %w(address city state_code zip_code country).map {|i| h(params: ["ticket_order[address][#{i}]"], messages: grape_error("coerce"))}
        }
        expect_api_validation_errors(JSON.parse(response.body), expected_errors)
      end
    end


    describe 'success' do

      before(:each) { 
      sign_in user_as_np_admin
      }
      let(:input_with_address) do
        {
          ticket_order: {
            address: {
            address: 'adddress',
            city: 'cityeee',
            state_code:"state code",
            zip_code: "532525",
            country: 'coutnwet'
        }
        }
      }
      end


      let(:input_address) { input_with_address[:ticket_order][:address]}

      let(:input_without_address) do 
        {
          ticket_order: {}
        }
      end

      def generate_expected(has_address=false)
        ret= h({id: ticket_order.id,
          supporter: h({id: ticket_order.supporter.id})
        })

        if (has_address) 
          ret[:address] = h({
            id: TransactionAddress.last.id,
            address: input_address[:address],
            city: input_address[:city],
            state_code: input_address[:state_code],
            zip_code: input_address[:zip_code],
            country: input_address[:country],
            fingerprint: AddressComparisons.calculate_hash(ticket_order.supporter.id, input_address[:address],
              input_address[:city],
              input_address[:state_code],
              input_address[:zip_code],
              input_address[:country]),
            supporter: h({id: ticket_order.supporter.id}),
            updated_at: Time.now
          })
        else
          ret[:address] = nil
        end
        ret
      end


      describe 'no address on the ticket_order' do
        it 'input has address' do

          input = input_with_address
          xhr :put, "/api/v1/ticket_order/#{ticket_order.id}", input, format: :json
          expect(response.status).to(eq(200), response.body)
          json_response = JSON.parse(response.body)
  
  
          expected = generate_expected(true)
  
  
          expect(expected).to eq json_response
          
        end
        
        it 'input does not have address' do
          input = input_without_address
          xhr :put, "/api/v1/ticket_order/#{ticket_order.id}", input, format: :json
          expect(response.status).to(eq(200), response.body)
          json_response = JSON.parse(response.body)
  
  
          expected = generate_expected(false)

          expect(expected).to eq json_response
        end
      end

      describe 'ticket_order has address' do
        before(:each) { ticket_order.create_address(address:'1', supporter: ticket_order.supporter)}

        it 'input has address' do
          address_id = ticket_order.address.id
          input = input_with_address
          xhr :put, "/api/v1/ticket_order/#{ticket_order.id}", input, format: :json
          expect(response.status).to eq 200
          json_response = JSON.parse(response.body)
  
  
          expected = generate_expected(true)
  
  
          expect(expected).to eq json_response
          expect(TransactionAddress.count).to eq 1
          expect(TransactionAddress.last.id).to eq address_id
        end
        it 'input does not have address' do
          address_id = ticket_order.address.id
          input = input_without_address
          xhr :put, "/api/v1/ticket_order/#{ticket_order.id}", input, format: :json
          expect(response.status).to(eq(200), response.body)
          json_response = JSON.parse(response.body)
  
  
          expected = generate_expected(false)
  
  
          expect(expected).to eq json_response
          expect(TransactionAddress.count).to eq 0
        end
      end

    #   it 'no address already' do

    #     # make sure on add is called
    #     expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_add)
    #     make_call_and_verify_response()

    #   end


    #   describe 'an identical address is in the db' do

    #     let(:address_matching_input) { TransactionAddress.create!({supporter: ticket_order.supporter}.merge(input_address))}

    #     let(:pre_input_address) {TransactionAddress.create!({supporter: ticket_order.supporter, transactionable: ticket}.merge(input_address).merge({country: 'ehtwetioh'})) }

    #     before(:each) do
    #       # just some address we're not going to have any more
    #       ticket_order.address = pre_input_address
    #       ticket_order.address.save!
    #       ticket_order.save!
    #       address_matching_input
    #     end

    #     it 'but its not used by anything else' do

    #       expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_use)
    #       expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_remove).with(pre_input_address)
    #       make_call_and_verify_response()


    #       ticket_order.reload
    #       expect(ticket_order.address).to eq address_matching_input
    #       expect(Address.where(id: pre_input_address.id).any?).to be_falsey
    #     end

    #     it 'used by another transaction so we dont delete the original address' do

    #       AddressToTransactionRelation.create!(address: pre_input_address, transactionable_id: 541254, transactionable_type: 'Ticket')
    #       expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to receive(:on_use)
    #       expect_any_instance_of(DefaultAddressStrategies::ManualStrategy).to_not receive(:on_remove)
    #       make_call_and_verify_response()


    #       ticket_order.reload
    #       expect(ticket_order.address).to eq address_matching_input
    #       expect(Address.where(id: pre_input_address.id).any?).to be_truthy
    #     end
    #   end
    end


  end
end