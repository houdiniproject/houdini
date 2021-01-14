# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe ObjectEvent::ModelExtensions do 

	let(:event_type) {'model.event_name'}
	class ClassWithoutToBuilder
		include ObjectEvent::ModelExtensions
		object_eventable
	end

	class ClassWithToBuilder
		include ObjectEvent::ModelExtensions
		object_eventable

		def to_builder(*expand)
			Jbuilder.new do |json|
				json.id 1
			end
		end
	end

	it 'raises NotImplementedError when no to_builder is defined by developer' do 
		obj = ClassWithoutToBuilder.new
		expect { obj.to_event event_type}.to raise_error(NotImplementedError)
	end

	it 'returns an proper event when to_builder is defined by developer' do 
		obj = ClassWithToBuilder.new
		expect(obj.to_event event_type).to eq({
			'id' => kind_of(String),
			'object' => 'object_event',
			'type' => event_type,
			'data' => {
				'object' => {
					'id' => 1
				}
			}
		})
	end
end