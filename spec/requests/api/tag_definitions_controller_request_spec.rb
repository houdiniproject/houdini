# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe Api::TagDefinitionsController, type: :request do
	let(:tag_definition) { create(:tag_definition_with_nonprofit) }
	let(:nonprofit) { tag_definition.nonprofit }
	let(:user) { create(:user) }

	before do
		tag_definition
		user.roles.create(name: 'nonprofit_associate', host: nonprofit)
	end

	describe 'GET /' do
		let(:nonprofit) { Nonprofit.first }

		context 'when logged in successfully' do
			before do
				sign_in user
				get "/api/nonprofits/#{nonprofit.id}/tag_definitions"
			end

			it {
				expect(response).to have_http_status(:success)
			}

			describe 'with a response' do
				subject(:json) do
					JSON.parse(response.body)
				end

				it {
					expect(json.count).to eq 1
				}

				describe 'and a first item' do
					subject(:first) { json[0] }

					it {
						is_expected.to include('object' => 'tag_definition')
					}

					it {
						is_expected.to include('id' => tag_definition.id)
					}

					it {
						is_expected.to include('name' => 'Tag Name')
					}

					it {
						is_expected.to include('nonprofit' => nonprofit.id)
					}

					it {
						is_expected.to include('deleted' => false)
					}

					it {
						is_expected.to include('url' =>
							a_string_matching(
								%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/tag_definitions/#{tag_definition.id}}
							))
					}
				end
			end
		end

		it 'returns http unauthorized when not logged in' do
			get "/api/nonprofits/#{nonprofit.id}/tag_definitions"
			expect(response).to have_http_status(:unauthorized)
		end
	end

	describe 'GET /:id' do
		context 'when logged in' do
			before do
				sign_in user
				get "/api/nonprofits/#{nonprofit.id}/tag_definitions/#{tag_definition.id}"
			end

			it {
				expect(response).to have_http_status(:success)
			}

			describe 'with a response' do
				subject do
					JSON.parse(response.body)
				end

				it {
					is_expected.to include('object' => 'tag_definition')
				}

				it {
					is_expected.to include('id' => tag_definition.id)
				}

				it {
					is_expected.to include('name' => 'Tag Name')
				}

				it {
					is_expected.to include('nonprofit' => nonprofit.id)
				}

				it {
					is_expected.to include('deleted' => false)
				}

				it {
					is_expected.to include('url' =>
						a_string_matching(
							%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/tag_definitions/#{tag_definition.id}}
						))
				}
			end
		end

		it 'returns unauthorized when not logged in' do
			get "/api/nonprofits/#{nonprofit.id}/tag_definitions/#{tag_definition.id}"
			expect(response).to have_http_status(:unauthorized)
		end
	end
end
