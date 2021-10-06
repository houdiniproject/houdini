# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe Api::SupportersController, type: :request do
	let(:supporter) { create(:supporter_with_fv_poverty) }
	let(:nonprofit) { supporter.nonprofit }
	let(:user) { create(:user) }

	before do
		supporter
		user.roles.create(name: 'nonprofit_associate', host: nonprofit)
	end

	describe 'GET /' do
		let(:nonprofit) { Nonprofit.first }

		context 'when logged in successfully' do
			before do
				sign_in user
				get "/api/nonprofits/#{nonprofit.id}/supporters"
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

					let(:id) { first['id'] }

					it {
						is_expected.to include('object' => 'supporter')
					}

					it {
						is_expected.to include('id' => supporter.id)
					}

					it {
						is_expected.to include('name' => 'Fake Supporter Name')
					}

					it {
						is_expected.to include('nonprofit' => nonprofit.id)
					}

					it {
						is_expected.to include('anonymous' => false)
					}

					it {
						is_expected.to include('deleted' => false)
					}

					it {
						is_expected.to include('merged_into' => nil)
					}

					it {
						is_expected.to include('organization' => nil)
					}

					it {
						is_expected.to include('phone' => nil)
					}

					it {
						is_expected.to include('supporter_addresses' => [id])
					}

					it {
						is_expected.to include('url' =>
							a_string_matching(%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}}))
					}
				end
			end
		end

		it 'returns http unauthorized when not logged in' do
			get "/api/nonprofits/#{nonprofit.id}/supporters"
			expect(response).to have_http_status(:unauthorized)
		end
	end

	describe 'GET /:id' do
		context 'when logged in' do
			before do
				sign_in user
				get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}"
			end

			it {
				expect(response).to have_http_status(:success)
			}

			describe 'with a response' do
				subject(:json) do
					JSON.parse(response.body)
				end

				let(:id) { json['id'] }

				it {
					is_expected.to include('object' => 'supporter')
				}

				it {
					is_expected.to include('id' => supporter.id)
				}

				it {
					is_expected.to include('name' => 'Fake Supporter Name')
				}

				it {
					is_expected.to include('nonprofit' => nonprofit.id)
				}

				it {
					is_expected.to include('anonymous' => false)
				}

				it {
					is_expected.to include('deleted' => false)
				}

				it {
					is_expected.to include('merged_into' => nil)
				}

				it {
					is_expected.to include('organization' => nil)
				}

				it {
					is_expected.to include('phone' => nil)
				}

				it {
					is_expected.to include('supporter_addresses' => [id])
				}

				it {
					is_expected.to include('url' =>
							a_string_matching(%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}}))
				}
			end
		end

		it 'returns unauthorized when not logged in' do
			get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}"
			expect(response).to have_http_status(:unauthorized)
		end
	end
end
