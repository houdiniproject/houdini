# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

require "rails_helper"

RSpec.describe Api::SupporterAddressesController do
  let(:supporter) { create(:supporter_with_fv_poverty) }
  let(:nonprofit) { supporter.nonprofit }
  let(:supporter_address) { supporter }
  let(:user) { create(:user) }

  before do
    supporter
    user.roles.create(name: "nonprofit_associate", host: nonprofit)
  end

  describe "GET /" do
    context "when logged in" do
      subject(:json) do
        response.parsed_body
      end

      before do
        sign_in user
        get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        expect(json["data"].count).to eq 1
      }

      context "with first item" do
        subject do
          json["data"][0]
        end

        it {
          is_expected.to include("object" => "supporter_address")
        }

        it {
          is_expected.to include("id" => supporter_address.id)
        }

        it {
          is_expected.to include("nonprofit" => nonprofit.id)
        }

        it {
          is_expected.to include("deleted" => false)
        }

        it {
          is_expected.to include("supporter" => supporter.id)
        }

        it {
          is_expected.to include("address" => supporter_address.address)
        }

        it {
          is_expected.to include("city" => supporter_address.city)
        }

        it {
          is_expected.to include("state_code" => supporter_address.state_code)
        }

        it {
          is_expected.to include("country" => supporter_address.country)
        }

        it {
          is_expected.to include("zip_code" => supporter_address.zip_code)
        }

        it {
          is_expected.to include("url" =>
            a_string_matching(
              %r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses/#{supporter_address.id}} # rubocop:disable Layout/LineLength
            ))
        }
      end

      it { is_expected.to include("first_page" => true) }
      it { is_expected.to include("last_page" => true) }
      it { is_expected.to include("current_page" => 1) }
      it { is_expected.to include("requested_size" => 25) }
      it { is_expected.to include("total_count" => 1) }
    end

    it "returns http unauthorized when not logged in" do
      get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /:id" do
    context "when logged in" do
      subject do
        response.parsed_body
      end

      before do
        sign_in user
        get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses/#{supporter_address.id}"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        is_expected.to include("object" => "supporter_address")
      }

      it {
        is_expected.to include("id" => supporter_address.id)
      }

      it {
        is_expected.to include("nonprofit" => nonprofit.id)
      }

      it {
        is_expected.to include("deleted" => false)
      }

      it {
        is_expected.to include("supporter" => supporter.id)
      }

      it {
        is_expected.to include("address" => supporter_address.address)
      }

      it {
        is_expected.to include("city" => supporter_address.city)
      }

      it {
        is_expected.to include("state_code" => supporter_address.state_code)
      }

      it {
        is_expected.to include("country" => supporter_address.country)
      }

      it {
        is_expected.to include("zip_code" => supporter_address.zip_code)
      }

      it {
        is_expected.to include("url" =>
          a_string_matching(
            %r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses/#{supporter_address.id}} # rubocop:disable Layout/LineLength
          ))
      }
    end

    it "returns http success when not logged in" do
      get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses/#{supporter_address.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
