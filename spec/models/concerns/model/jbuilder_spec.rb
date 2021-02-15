# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe Model::Jbuilder do 


	class ClassCustomToId
		def initialize(id)
			@id = id
		end

		def get_id 
			@id
		end

		def get_builder
			Jbuilder.new do |json|
				json.id @id
			end
		end
	end
	
	class ClassWithId
		attr_reader :id
		def initialize(id)
			@id = id
		end

		def to_builder
			Jbuilder.new do |json|
				json.id id
			end
		end
	end

	class ClassWithJbuilder
		include Model::Jbuilder
	
		add_builder_expansion :expandable_item, :expandable_array, :shrunk_item
		add_builder_expansion :shrunk_array, json_attrib: :shrunk_array_name
		
		add_builder_expansion :custom_to_expandable, to_id:  -> (model) { model.get_id}, to_expand: ->(model) {model.get_builder}

		add_builder_expansion :custom_to_shrunk, to_id:  -> (model) { model.get_id}, to_expand: ->(model) {model.get_builder}

		def expandable_item 
			ClassWithId.new('expandable_item')
		end

		def expandable_array
			[ClassWithId.new('expandable_array_1'), ClassWithId.new('expandable_array_2')]
		end

		def custom_to_shrunk
			ClassCustomToId.new('custom_item')
		end

		def custom_to_expandable
			[ClassCustomToId.new('custom_item_to_expandable_1'), ClassCustomToId.new('custom_item_to_expandable_2')]
		end

		def shrunk_item 
			ClassWithId.new('shrunk_item')
		end

		def shrunk_array
			[ClassWithId.new('shunk_array_1'), ClassWithId.new('shrunk_array_2')]
		end

		def id
			"main_id"
		end

		def to_builder()
			init_builder(:expandable_item, :expandable_array, :custom_to_expandable) do |json|
				json.custom_attrib 'custom_attrib'
			end
		end
	end

	class ClassWithExpandAllJbuilder
		include Model::Jbuilder
	
		add_builder_expansion :expandable_item

		def id
			'id'
		end

		def expandable_item 
			ClassWithId.new('expandable_item')
		end

		def to_builder()
			init_builder(:all)
		end
	end


	let(:builder) { ClassWithJbuilder.new.to_builder.attributes!}
	let(:expand_all_builder) { ClassWithExpandAllJbuilder.new.to_builder.attributes!}

	it 'matches expected for normal expansion rules' do
		expect(builder).to eq({
			'id' => 'main_id',
			'custom_attrib' => 'custom_attrib',
			'custom_to_shrunk' => 'custom_item',
			'custom_to_expandable' => [{'id'=> 'custom_item_to_expandable_1'}, {'id' => 'custom_item_to_expandable_2'}],
			'shrunk_array_name' => ['shunk_array_1', 'shrunk_array_2'],
			'shrunk_item' => 'shrunk_item',
			'expandable_item' => {
				'id' => 'expandable_item'
			},
			'object' => 'class_with_jbuilder',
			'expandable_array' => [{'id'=> 'expandable_array_1'}, {'id' => 'expandable_array_2'}]
		})
	end

	it 'matches expected for expand all rules' do 
		expect(expand_all_builder).to eq({
			'expandable_item' => {
				'id' => 'expandable_item'
			},
			'id' => 'id',
			"object" => "class_with_expand_all_jbuilder"
		})
	end
end