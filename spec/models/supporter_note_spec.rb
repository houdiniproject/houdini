# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe SupporterNote, type: :model do
  include_context :shared_donation_charge_context
  let(:content) { "CONTENT"}
  let(:content2) {"CONTENT2"}

  let(:supporter_note) { supporter.supporter_notes.create(content: content, user: user) }
  it 'creates' do 
    expect(supporter_note.errors).to be_empty
  end

  it 'announces created' do
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_note_created, {
      'id' => kind_of(String),
      'object' => 'object_event',
      'type' => 'supporter_note.created',
      'data' => {
        'object' => {
          'id'=> kind_of(Numeric),
          'deleted' => false,
          'content' => content,
          'nonprofit'=> {
            'id' => nonprofit.id,
            'name' => nonprofit.name,
            'object' => 'nonprofit'
          },
          'object' => 'supporter_note',
          'user' => {
            'id' => user.id,
            'object' => 'user'
          },
          'supporter' => {
            'id' => supporter.id,
            'object' => 'supporter'
          }
        }
      }
    })

    supporter_note
  end

  it 'announces updated' do
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_note_created, anything).ordered
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_note_updated, {
      'id' => kind_of(String),
      'object' => 'object_event',
      'type' => 'supporter_note.updated',
      'data' => {
        'object' => {
          'id'=> kind_of(Numeric),
          'deleted' => false,
          'content' => content2,
          'nonprofit'=> {
            'id' => nonprofit.id,
            'name' => nonprofit.name,
            'object' => 'nonprofit'
          },
          'object' => 'supporter_note',
          'user' => {
            'id' => user.id,
            'object' => 'user'
          },
          'supporter' => {
            'id' => supporter.id,
            'object' => 'supporter'
          }
        }
      }
    }).ordered

    supporter_note
    supporter_note.content = content2
    supporter_note.save!
  end
  
  it 'announces deleted' do
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_note_created, anything).ordered
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_note_deleted, {
      'id' => kind_of(String),
      'object' => 'object_event',
      'type' => 'supporter_note.deleted',
      'data' => {
        'object' => {
          'id'=> kind_of(Numeric),
          'deleted' => true,
          'content' => content,
          'nonprofit'=> {
            'id' => nonprofit.id,
            'name' => nonprofit.name,
            'object' => 'nonprofit'
          },
          'object' => 'supporter_note',
          'user' => {
            'id' => user.id,
            'object' => 'user'
          },
          'supporter' => {
            'id' => supporter.id,
            'object' => 'supporter'
          }
        }
      }
    }).ordered
    
    supporter_note.discard!

  end
end
