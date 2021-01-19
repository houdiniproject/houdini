# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe Supporter, type: :model do
	include_context :shared_donation_charge_context
	let(:name) {"CUSTOM SSUPPORTER"}
	let(:merged_into_supporter_name) {"I've been merged into!"}
	let(:address) { "address for supporter"}
	let(:supporter) { nonprofit.supporters.create(name: name, address: address)}
	let(:merged_supporter) {nonprofit.supporters.create(name: name, address: address, merged_into: merged_into_supporter, deleted: true) }
	let(:merged_into_supporter) {nonprofit.supporters.create(name: merged_into_supporter_name, address: address) }

	let(:supporter_base) do
		{
			'anonymous' => false,
			'deleted' => false,
			'name' => name,
			'organization' => nil,
			'phone' => nil,
			'supporter_addresses' => [kind_of(Numeric)],
			'id'=> kind_of(Numeric),
			'merged_into' => nil,
			'nonprofit'=> nonprofit.id,
			'object' => 'supporter'
		}
	end

	let(:supporter_address_base) do 
		{
			'id' =>  kind_of(Numeric),
			'deleted' => false,
			'address' => address,
			'city' => nil,
			'state_code' => nil,
			'zip_code' => nil,
			'country' => 'United States',
			'object' => 'supporter_address',
			'supporter' => kind_of(Numeric)
		}
	end

	let(:nonprofit_base) do 
			{
				'id' => nonprofit.id,
				'name' => nonprofit.name,
				'object' => 'nonprofit'
			}
	end

	describe 'supporter' do
		it 'created' do

			supporter_result = supporter_base.merge({
				'supporter_addresses' => [
					supporter_address_base
				],
				'nonprofit' => nonprofit_base
			})

			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, {
        'id' => kind_of(String),
        'object' => 'object_event',
        'type' => 'supporter.created',
        'data' => {
          'object' => supporter_result
        }
			}).ordered
			
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered

      supporter
		end

		it 'deletes' do 
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created,anything).ordered
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered
			expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_updated)
			expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_address_updated)

			supporter_result = supporter_base.merge({
				'deleted' => true,
				'supporter_addresses' => [
					supporter_address_base.merge({'deleted' => true})
				],
				'nonprofit' => nonprofit_base
			})

			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_deleted, {
        'id' => kind_of(String),
        'object' => 'object_event',
        'type' => 'supporter.deleted',
        'data' => {
          'object' => supporter_result
        }
			}).ordered


			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_deleted,anything).ordered

			supporter.discard!
		end
	end

	describe 'supporter_address events' do
		it 'creates' do 
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered



			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, {
				'id' => kind_of(String),
				'object' => 'object_event',
				'type' => 'supporter_address.created',
				'data' => {
					'object' => supporter_address_base.merge({
						'supporter' =>  supporter_base
					})
				}
			}).ordered

			supporter
		end

		it 'deletes' do 
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created,anything).ordered
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered
			expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_updated)
			expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_address_updated)

			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_deleted, anything)

		
			supporter_address_result = supporter_address_base.merge({
				'deleted' => true,
				'supporter'=> supporter_base.merge({'deleted' => true})
			})

			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_deleted, {
        'id' => kind_of(String),
        'object' => 'object_event',
        'type' => 'supporter_address.deleted',
        'data' => {
          'object' => supporter_address_result
        }
			}).ordered
			

			supporter.discard!
		end
	end

	describe 'supporter and supporter_address events update events are separate' do 
		it 'only fires supporter on supporter only change' do 
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered
			
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_updated, {	'id' => kind_of(String),
			'object' => 'object_event',
			'type' => 'supporter.updated',
			'data' => {
				'object' => supporter_base.merge({
					'name' => merged_into_supporter_name,
					'supporter_addresses' => [
 						supporter_address_base
					],
					'nonprofit' => nonprofit_base
				})
	
			}}).ordered
			expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_address_updated, anything)

			supporter.update(name: merged_into_supporter_name)
		end

		it 'only fires supporter_address on supporter_address only change' do 
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered
			
			expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_updated, {	
			'id' => kind_of(String),
			'object' => 'object_event',
			'type' => 'supporter_address.updated',
			'data' => {
				'object' => supporter_address_base.merge({
					'city' => 'new_city',
					'supporter'=> supporter_base
				})
			}}).ordered

			#expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_updated, anything)

			supporter.update(city: 'new_city')
		end
	end
end