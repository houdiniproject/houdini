# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe Model::Houidable do 

	let(:prefix) { :trxassign}
	let(:preset_houid) { "test_eoiathotih"}
	
	let(:default_trxassign){ TransactionAssignment.new }

	let(:already_set_houid) {TransactionAssignment.new(id: preset_houid)}

	it 'sets houid_prefix' do 
		expect(default_trxassign.houid_prefix).to eq prefix
	end

	it 'generates a valid houid' do 
		expect(default_trxassign.generate_houid).to match_houid(prefix)
	end

	it 'sets a valid houid as id' do 
		expect(default_trxassign.id).to match_houid(prefix)
	end

	it 'will not override an id if already set' do
		expect(already_set_houid.id).to eq preset_houid
	end

	it 'fires the before_houid_set callback' do 
		class WithBeforeHouidSetCallback < TransactionAssignment
			mattr_accessor :callback_handler
			before_houid_set ->(model) { self.class.callback_handler.before_houid_set_callback(model) }
		end

		WithBeforeHouidSetCallback.callback_handler = double('Before Callback Handler')
		expect(WithBeforeHouidSetCallback.callback_handler).to receive(:before_houid_set_callback).with(having_attributes(id: nil))
		WithBeforeHouidSetCallback.new
	end

	it 'fires the after_houid_set callback' do 
		class WithAfterHouidSetCallback < TransactionAssignment
			mattr_accessor :callback_handler
			after_houid_set ->(model) { self.class.callback_handler.after_houid_set_callback(model) }
		end

		WithAfterHouidSetCallback.callback_handler = double('After Callback Handler')
		expect(WithAfterHouidSetCallback.callback_handler).to receive(:after_houid_set_callback).with(having_attributes(id: match_houid(:trxassign)))
		WithAfterHouidSetCallback.new
	end
end