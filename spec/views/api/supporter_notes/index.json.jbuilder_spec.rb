# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe '/api/supporter_notes/index.json.jbuilder', type: :view do
	subject(:json) do
		assign(:supporter_notes, [supporter_note_with_fv_poverty_with_user])
		render
		JSON.parse(rendered)
	end

	let(:supporter_note_with_fv_poverty_with_user) { create(:supporter_note_with_fv_poverty_with_user) }

	it { expect(json.count).to eq 1 }

	describe 'details of the first item' do
		subject(:first) do
			json.first
		end

		let(:supporter_note) { supporter_note_with_fv_poverty_with_user }

		let(:supporter) { supporter_note.supporter }
		let(:nonprofit) { supporter.nonprofit }
		let(:user) { supporter_note.user }

		it {
			is_expected.to include('object' => 'supporter_note')
		}

		it {
			is_expected.to include('id' => supporter_note.id)
		}

		it {
			is_expected.to include('content' => 'Some content in our note')
		}

		it {
			is_expected.to include('nonprofit' => nonprofit.id)
		}

		it {
			is_expected.to include('deleted' => false)
		}

		it {
			is_expected.to include('supporter' => supporter.id)
		}

		it {
			is_expected.to include('user' => user.id)
		}

		it {
			is_expected.to include('url' =>
				a_string_matching(
					%r{http://test\.host/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}} # rubocop:disable Layout/LineLength
				))
		}
	end
end
