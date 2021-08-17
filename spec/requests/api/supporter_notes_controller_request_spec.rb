# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

require 'rails_helper'

RSpec.describe Api::SupporterNotesController, type: :request do
	let(:supporter) { supporter_note.supporter }
	let(:nonprofit) { supporter.nonprofit }
	let(:supporter_note) { create(:supporter_note_with_fv_poverty_with_user) }
	let(:user) { supporter_note.user }

	before do
		supporter
		user.roles.create(name: 'nonprofit_associate', host: nonprofit)
	end

	describe 'GET /' do
		context 'when logged in' do
			subject(:json) do
				JSON.parse(response.body)
			end

			before do
				sign_in user
				get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes"
			end

			it {
				expect(response).to have_http_status(:success)
			}

			it {
				expect(json.count).to eq 1
			}

			context 'with first item' do
				subject do
					json[0]
				end

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
							%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}} # rubocop:disable Layout/LineLength
						))
				}
			end
		end

		it 'returns http unauthorized when not logged in' do
			get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes"
			expect(response).to have_http_status(:unauthorized)
		end
	end

	describe 'GET /:id' do
		context 'when logged in' do
			subject do
				JSON.parse(response.body)
			end

			before do
				sign_in user
				get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}"
			end

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
						%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}} # rubocop:disable Layout/LineLength
					))
			}
		end

		it 'returns http success when not logged in' do
			get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}"
			expect(response).to have_http_status(:unauthorized)
		end
	end
end
