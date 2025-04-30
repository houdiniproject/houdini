# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe ApiNew::SupportersController, type: :request do
  let(:supporter) { create(:supporter_with_fv_poverty, :with_primary_address) }
  let(:nonprofit) { supporter.nonprofit }

  let(:user) { create(:user) }

  before do
    supporter
    user.roles.create(name: "nonprofit_associate", host: nonprofit)
  end
  describe "routing for" do
    describe "api_new_nonprofit_supporter_path" do
      subject { api_new_nonprofit_supporter_path(nonprofit.to_modern_param, supporter.to_modern_param) }
      it { is_expected.to eq "/api_new/nonprofits/#{nonprofit.houid}/supporters/#{supporter.houid}" }
    end

    describe "api_new_nonprofit_supporter_path" do
      subject { api_new_nonprofit_supporter_url(nonprofit.to_modern_param, supporter.to_modern_param) }
      it { is_expected.to eq "http://www.example.com/api_new/nonprofits/#{nonprofit.houid}/supporters/#{supporter.houid}" }
    end
  end

  describe "GET /:id" do
    context "when logged in" do
      before do
        sign_in user
        get "/api_new/nonprofits/#{nonprofit.houid}/supporters/#{supporter.houid}"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      describe "with a response" do
        subject(:json) do
          JSON.parse(response.body)
        end

        let(:id) { json["id"] }

        it {
          is_expected.to include("object" => "supporter")
        }

        it {
          is_expected.to include("id" => supporter.houid)
        }

        it {
          is_expected.to include("name" => "Fake Supporter Name")
        }

        it {
          is_expected.to include("nonprofit" => nonprofit.houid)
        }

        it {
          is_expected.to include("anonymous" => false)
        }

        it {
          is_expected.to include("deleted" => false)
        }

        it {
          is_expected.to include("merged_into" => nil)
        }

        it {
          is_expected.to include("organization" => nil)
        }

        it {
          is_expected.to include("phone" => nil)
        }

        describe "supporter_addresses" do
          subject(:addresses) { json["supporter_addresses"] }
          it {
            expect(addresses.count).to eq 1
          }
          describe " with the only address" do
            subject(:sole_address) { addresses.first }
            it {
              is_expected.to include("address" => supporter.address)
            }

            it {
              is_expected.to include("city" => supporter.city)
            }

            it {
              is_expected.to include("state_code" => supporter.state_code)
            }

            it {
              is_expected.to include("zip_code" => supporter.zip_code)
            }

            it {
              is_expected.to include("country" => supporter.country)
            }
          end
        end

        # it {
        # 	is_expected.to include('url' =>
        # 			a_string_matching(%r{http://www\.example\.com/api_new/nonprofits/#{nonprofit.houid}/supporters/#{supporter.houid}}))
        # }
      end
    end
    it "returns unauthorized when not logged in" do
      get "/api_new/nonprofits/#{nonprofit.houid}/supporters/#{supporter.houid}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
