# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe '/api/ticket_levels/index.json.jbuilder', type: :view do
	subject(:json) do
		assign(:ticket_levels, [
										ticket_level_with_event_non_admin__order_3__not_deleted
									])
		render
		JSON.parse(rendered)
	end

	def base_path(nonprofit_id, event_id, ticket_level_id)
		"/api/nonprofits/#{nonprofit_id}/events/#{event_id}/ticket_levels/#{ticket_level_id}"
	end

	def base_url(nonprofit_id, event_id, ticket_level_id)
		"http://test.host#{base_path(nonprofit_id, event_id, ticket_level_id)}"
	end

	let(:ticket_level_with_event_non_admin__order_3__not_deleted) do
		create(:ticket_level_with_event_non_admin__order_3__not_deleted)
	end

	it { expect(json.count).to eq 1 }

	describe 'details of the :ticket_level_with_event_non_admin__order_3__not_deleted' do
		subject do
			json[0]
		end

		let(:ticket_level) { ticket_level_with_event_non_admin__order_3__not_deleted }
		let(:event) { ticket_level.event }
		let(:nonprofit) { ticket_level.nonprofit }

		include_context 'json results for ticket_level_with_event_non_admin__order_3__not_deleted'
	end
end
