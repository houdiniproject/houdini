# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Api::SupportersController do
  let(:supporter) { create(:supporter_with_fv_poverty) }
  let(:nonprofit) { supporter.nonprofit }
  let(:user) { create(:user) }

  before do
    supporter
    user.roles.create(name: "nonprofit_associate", host: nonprofit)
  end

  describe "GET /" do
    context "when logged in successfully" do
      before do
        sign_in user
        get "/api/nonprofits/#{nonprofit.id}/supporters"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      describe "with a response" do
        subject(:json) do
          response.parsed_body
        end

        it {
          is_expected.to include("data" => have_attributes(count: 1))
        }

        describe "and a first item" do
          subject(:first) { json["data"][0] }

          let(:id) { first["id"] }

          it {
            is_expected.to include("object" => "supporter")
          }

          it {
            is_expected.to include("id" => supporter.id)
          }

          it {
            is_expected.to include("name" => "Fake Supporter Name")
          }

          it {
            is_expected.to include("nonprofit" => nonprofit.id)
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

          it {
            is_expected.to include("supporter_addresses" => [id])
          }

          it {
            is_expected.to include("url" =>
              a_string_matching(%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}}))
          }
        end
      end

      context "when paging" do
        before do
          supporter
          6.times do |i|
            create(:supporter_with_fv_poverty, nonprofit: supporter.nonprofit, name: i, email: "email#{i}@email#{i}.com")
          end
          sign_in user
        end

        context "when on page 0" do
          subject(:json) do
            response.parsed_body
          end

          before do
            get "/api/nonprofits/#{nonprofit.id}/supporters", params: {page: 0, per: 5}
          end

          it { is_expected.to include("data" => have_attributes(count: 5)) }
          it { is_expected.to include("first_page" => true) }
          it { is_expected.to include("last_page" => false) }
          it { is_expected.to include("current_page" => 1) }
          it { is_expected.to include("requested_size" => 5) }
          it { is_expected.to include("total_count" => 7) }
        end

        context "when on page 1" do
          subject(:json) do
            response.parsed_body
          end

          before do
            get "/api/nonprofits/#{nonprofit.id}/supporters", params: {page: 1, per: 5}
          end

          it { is_expected.to include("data" => have_attributes(count: 5)) }
          it { is_expected.to include("first_page" => true) }
          it { is_expected.to include("last_page" => false) }
          it { is_expected.to include("current_page" => 1) }
          it { is_expected.to include("requested_size" => 5) }
          it { is_expected.to include("total_count" => 7) }

          it {
            expect(json["data"].pluck("id")).to eq Supporter.order("id DESC").limit(5).pluck(:id)
          }
        end

        context "when on page 2" do
          subject(:json) do
            response.parsed_body
          end

          before do
            get "/api/nonprofits/#{nonprofit.id}/supporters", params: {page: 2, per: 5}
          end

          it { is_expected.to include("data" => have_attributes(count: 2)) }
          it { is_expected.to include("first_page" => false) }
          it { is_expected.to include("last_page" => true) }
          it { is_expected.to include("current_page" => 2) }
          it { is_expected.to include("requested_size" => 5) }
          it { is_expected.to include("total_count" => 7) }

          it {
            expect(json["data"].pluck("id")).to eq Supporter.order("id DESC").limit(2).offset(5).pluck(:id)
          }
        end
      end
    end

    it "returns http unauthorized when not logged in" do
      get "/api/nonprofits/#{nonprofit.id}/supporters"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /:id" do
    context "when logged in" do
      before do
        sign_in user
        get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      describe "with a response" do
        subject(:json) do
          response.parsed_body
        end

        let(:id) { json["id"] }

        it {
          is_expected.to include("object" => "supporter")
        }

        it {
          is_expected.to include("id" => supporter.id)
        }

        it {
          is_expected.to include("name" => "Fake Supporter Name")
        }

        it {
          is_expected.to include("nonprofit" => nonprofit.id)
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

        it {
          is_expected.to include("supporter_addresses" => [id])
        }

        it {
          is_expected.to include("url" =>
              a_string_matching(%r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}}))
        }
      end
    end

    it "returns unauthorized when not logged in" do
      get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
