# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

require "rails_helper"

RSpec.describe Api::SupporterNotesController do
  let(:supporter) { supporter_note.supporter }
  let(:nonprofit) { supporter.nonprofit }
  let(:supporter_note) { create(:supporter_note_with_fv_poverty_with_user) }
  let(:user) { supporter_note.user }

  before do
    supporter
    user.roles.create(name: "nonprofit_associate", host: nonprofit)
  end

  describe "GET /" do
    context "when logged in" do
      subject(:json) do
        response.parsed_body
      end

      describe "with a response" do
        before do
          sign_in user
          get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes"
        end

        it {
          expect(response).to have_http_status(:success)
        }

        it {
          is_expected.to include("data" => have_attributes(count: 1))
        }

        context "with first item" do
          subject do
            json["data"][0]
          end

          it {
            is_expected.to include("object" => "supporter_note")
          }

          it {
            is_expected.to include("id" => supporter_note.id)
          }

          it {
            is_expected.to include("content" => "Some content in our note")
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
            is_expected.to include("user" => user.id)
          }

          it {
            is_expected.to include("url" =>
              a_string_matching(
                %r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}} # rubocop:disable Layout/LineLength
              ))
          }
        end
      end

      context "when paging" do
        before do
          6.times do |i|
            create(:supporter_note_with_fv_poverty_with_user, supporter: supporter, content: "content for #{i}")
          end
          sign_in user
        end

        context "when on page 0" do
          subject(:json) do
            response.parsed_body
          end

          before do
            get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes", params: {page: 0, per: 5}
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
            get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes", params: {page: 1, per: 5}
          end

          it { is_expected.to include("data" => have_attributes(count: 5)) }
          it { is_expected.to include("first_page" => true) }
          it { is_expected.to include("last_page" => false) }
          it { is_expected.to include("current_page" => 1) }
          it { is_expected.to include("requested_size" => 5) }
          it { is_expected.to include("total_count" => 7) }

          it {
            expect(json["data"].pluck("id")).to eq SupporterNote.order("id DESC").limit(5).pluck(:id)
          }
        end

        context "when on page 2" do
          subject(:json) do
            response.parsed_body
          end

          before do
            get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes", params: {page: 2, per: 5}
          end

          it { is_expected.to include("data" => have_attributes(count: 2)) }
          it { is_expected.to include("first_page" => false) }
          it { is_expected.to include("last_page" => true) }
          it { is_expected.to include("current_page" => 2) }
          it { is_expected.to include("requested_size" => 5) }
          it { is_expected.to include("total_count" => 7) }

          it {
            expect(json["data"].pluck("id")).to eq SupporterNote.order("id DESC").limit(2).offset(5).pluck(:id)
          }
        end
      end
    end

    it "returns http unauthorized when not logged in" do
      get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes"
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
        get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}"
      end

      it {
        is_expected.to include("object" => "supporter_note")
      }

      it {
        is_expected.to include("id" => supporter_note.id)
      }

      it {
        is_expected.to include("content" => "Some content in our note")
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
        is_expected.to include("user" => user.id)
      }

      it {
        is_expected.to include("url" =>
          a_string_matching(
            %r{http://www\.example\.com/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}} # rubocop:disable Layout/LineLength
          ))
      }
    end

    it "returns http success when not logged in" do
      get "/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
