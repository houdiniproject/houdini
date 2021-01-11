# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe TagMaster, type: :model do
  include_context :shared_donation_charge_context
  let(:name) { "TAGNAME"}

  let(:tag_master) { nonprofit.tag_masters.create(name: name) }
  it 'creates' do 
    expect(tag_master.errors).to be_empty
  end

  it 'announces create' do
    expect(Houdini.event_publisher).to receive(:announce).with(:tag_master_created, {
      'id' => kind_of(String),
      'object' => 'object_event',
      'type' => 'tag_master.created',
      'data' => {
        'object' => {
          'id'=> kind_of(Numeric),
          'deleted' => false,
          'name' => name,
          'nonprofit'=> nonprofit.id,
          'object' => 'tag_master'
        }
      }
    })

    tag_master
  end
  
  it 'announces deleted' do
    expect(Houdini.event_publisher).to receive(:announce).with(:tag_master_created, anything).ordered
    expect(Houdini.event_publisher).to receive(:announce).with(:tag_master_deleted, {
      'id' => kind_of(String),
      'object' => 'object_event',
      'type' => 'tag_master.deleted',
      'data' => {
        'object' => {
          'id'=> kind_of(Numeric),
          'deleted' => true,
          'name' => name,
          'nonprofit'=> nonprofit.id,
          'object' => 'tag_master'
        }
      }
    }).ordered
    
    tag_master.discard!

  end
end
